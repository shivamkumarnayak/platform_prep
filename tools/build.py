import re, json, os, pickle, warnings, shutil, subprocess
import pdfplumber
import pypdfium2 as pdfium
from PIL import Image
warnings.filterwarnings('ignore')

PDF = '/mnt/user-data/uploads/RRB_JE_CBT_1_Key_Hindi.pdf'
OUT = '/home/claude/app_assets'
S = pickle.load(open('/home/claude/stage1.pkl', 'rb'))
poppler, pages = S['poppler'], S['pages']

SCALE = 2.4          # px per pt for cropped images
WRAP_X = 380         # a line ending right of this is a soft-wrapped line

plum = pdfplumber.open(PDF)
pdfi = pdfium.PdfDocument(PDF)

# ---- test metadata from raw text ----
raw = subprocess.run(['pdftotext', '-layout', PDF, '-'], capture_output=True, text=True).stdout
metas = re.findall(r'Test Date\s+(\d\d)/(\d\d)/(\d{4})\s*\n\s*Test Time\s+([\d:]+ [AP]M) - ([\d:]+ [AP]M)', raw)
MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
assert len(metas) == 7, metas


def icon_img(im):
    return im['x1'] <= 82 and (im['x1'] - im['x0']) <= 20 and (im['bottom'] - im['top']) <= 14


def fullpg(im):
    return (im['x1'] - im['x0']) > 540 and ((im['bottom'] - im['top']) > 780 or im['top'] < 130)


def icon_rect(r):
    w = r['x1'] - r['x0']; h = r['bottom'] - r['top']
    return 10 <= w <= 20 and 9 <= h <= 14 and r['x0'] <= 82


def has_gfx(pg, H, top, bot, xmin):
    """True when the region holds content images or non-cell vector graphics."""
    for im in pg.images:
        if icon_img(im) or fullpg(im):
            continue
        if im['top'] < bot and im['bottom'] > top and im['x1'] > xmin:
            return True
    for kind in ('rects', 'lines', 'curves'):
        for r in getattr(pg, kind):
            cy = (r['top'] + r['bottom']) / 2
            if not (top <= cy < bot):
                continue
            if r['x0'] <= 57.6 or r['x1'] >= 575 or r['top'] > H - 45:
                continue
            if icon_rect(r):
                continue
            if r['x0'] < xmin - 1:
                continue
            return True
    return False


def words_in(pi, top, bot, xmin, skip=None):
    out = []
    H = pages[pi]['H']
    for w in poppler[pi]:
        cy = (w['y0'] + w['y1']) / 2
        if not (top <= cy < bot) or w['x0'] < xmin or w['y0'] > H - 5:
            continue
        if (w['x1'] - w['x0']) / max(1, len(w['t'])) > 14:   # wide watermark glyph pieces
            continue
        t = w['t'].replace('\u200b', '')
        if not t.strip():
            continue
        if skip and skip(w):
            continue
        out.append(dict(w, t=t))
    return out



FIXES = [
    (r'के (?=(वल|न्द्र|शव|रल))', 'के'),
    (r'कें (?=द्र)', 'कें'),
    (r'(?<=कू) (?=[\u0900-\u097F])', ''),
    (r'(?<=कु) (?=[\u0900-\u097F])', ''),
    (r'(?<=कृ) (?=[\u0900-\u097F])', ''),
    (r'(?<![\u0900-\u097F])दू (?=[\u0900-\u097F])', 'दू'),
    (r'प्रदू (?=[\u0900-\u097F])', 'प्रदू'),
    (r'ऊँ (?=च)', 'ऊँ'),
    (r'कें (?=चु)', 'कें'),
    (r'तरं (?=ग)', 'तरं'),
    (r'तार्कि (?=क)', 'तार्कि'),
]


def repair(text):
    for pat, rep in FIXES:
        text = re.sub(pat, rep, text)
    return text


def to_text(ws):
    if not ws:
        return ''
    ws = sorted(ws, key=lambda w: (w['y0'] + w['y1']) / 2)
    lines = []
    for w in ws:
        cy = (w['y0'] + w['y1']) / 2
        if lines and abs(cy - lines[-1]['cy']) <= 5:
            lines[-1]['ws'].append(w)
        else:
            lines.append(dict(cy=cy, ws=[w]))
    strs = []
    for ln in lines:
        l = sorted(ln['ws'], key=lambda w: w['x0'])
        s = l[0]['t']
        for a, b in zip(l, l[1:]):
            s += (b['t'] if b['x0'] - a['x1'] < 1.0 else ' ' + b['t'])
        strs.append((s, max(w['x1'] for w in l)))
    text = strs[0][0]
    for (ps, px), (s, _) in zip(strs, strs[1:]):
        text += (' ' if px >= WRAP_X else '\n') + s
    return repair(re.sub(r'[ \t]+', ' ', text).strip())


render_cache = {}


def page_img(pi):
    if pi not in render_cache:
        render_cache.clear()
        render_cache[pi] = pdfi[pi].render(scale=SCALE).to_pil().convert('RGB')
    return render_cache[pi]


def save_crop(pi, x0, y0, x1, y1, path, neutral=False):
    im = page_img(pi)
    box = (int(x0 * SCALE), int(y0 * SCALE), int(x1 * SCALE), int(y1 * SCALE))
    c = im.crop(box)
    # wash out the pale watermark / background tint: near-white -> white
    import numpy as np
    arr = np.array(c)
    r, g, b = arr[..., 0].astype(int), arr[..., 1].astype(int), arr[..., 2].astype(int)
    mask = (r > 222) & (g > 208) & (b > 208) & (abs(r - g) < 40)
    arr[mask] = (255, 255, 255)
    if neutral:
        # remove green/red answer-key coloring so option images never reveal the answer
        r, g, b = arr[..., 0].astype(int), arr[..., 1].astype(int), arr[..., 2].astype(int)
        gm = (g > r + 30) & (g > b + 30)
        rm = (r > g + 50) & (r > b + 50)
        cm = gm | rm
        mn = np.minimum(np.minimum(r, g), b)
        mn = np.where(mn < 110, 37, mn)
        for ch in range(3):
            arr[..., ch] = np.where(cm, mn, arr[..., ch])
    c = Image.fromarray(arr)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    c.save(path, optimize=True)


# ---- walk all blocks ----
def cell_at(cells, y):
    for t, b in cells:
        if t - 0.8 <= y <= b + 0.8:
            return (t, b)
    return None


tests = []
cur = None
stats = dict(qimg=0, oimg=0, empty_stem=0, empty_opt=0, nocell=0)
for pi, p in enumerate(pages):
    pg = plum.pages[pi]
    a = p['anchors']; H = p['H']
    cells = sorted({(round(r['top'], 1), round(r['bottom'], 1)) for r in pg.rects
                    if abs(r['x0'] - 57.0) < 0.8 and abs(r['x1'] - 576.5) < 0.8})
    for i, an in enumerate(a):
        top = an['top'] - 6
        bot = a[i + 1]['top'] - 6 if i + 1 < len(a) else H
        toks = [t for t in p['toks'] if top <= t['top'] < bot]
        assert [t['n'] for t in toks] == [1, 2, 3, 4]
        correct = [t['n'] - 1 for t in toks if t['green']]
        assert len(correct) == 1
        if an['q'] == 1:
            cur = dict(questions=[])
            tests.append(cur)
        tno = len(tests)

        # row-cell geometry (falls back to estimates if a cell is missing)
        c0 = cell_at(cells, an['top'] + 5)
        stem_top = c0[0] if c0 else an['top'] - 4
        o_tops = []
        for t in toks:
            c = cell_at(cells, (t['top'] + t['bottom']) / 2)
            if not c:
                stats['nocell'] += 1
            o_tops.append(c[0] if c else t['top'] - 3)
        last_cells = [b for (tt, b) in cells if tt >= o_tops[3] - 0.8 and b <= bot + 1]
        o_end = max(last_cells) if last_cells else bot
        stem_bot = o_tops[0]

        stem_txt = to_text(words_in(pi, top, stem_bot, 50))
        q = dict(n=an['q'], q=stem_txt, o=[], a=correct[0])
        if has_gfx(pg, H, stem_top, stem_bot, 50):
            fn = f'images/t{tno}/q{an["q"]:03d}.png'
            save_crop(pi, 58, stem_top + 0.6, 575, stem_bot - 0.4, f'{OUT}/{fn}')
            q['qi'] = fn
            stats['qimg'] += 1
        elif not stem_txt:
            stats['empty_stem'] += 1
        qo_img = {}
        for k, t in enumerate(toks):
            o_top = o_tops[k]
            o_bot = o_tops[k + 1] if k + 1 < 4 else (o_end if k == 3 else bot)
            ow = words_in(pi, o_top - 0.5, o_bot + (0 if k < 3 else 2), 50,
                          skip=lambda w, t=t: abs(w['x0'] - t['x0']) < 3 and w['t'] == f'{t["n"]}.')
            ow = [w for w in ow if not (w['x0'] < 50)]
            txt = to_text(ow)
            q['o'].append(txt)
            if has_gfx(pg, H, o_top, o_bot, 80):
                fn = f'images/t{tno}/q{an["q"]:03d}_o{k + 1}.png'
                save_crop(pi, 86.5, o_top + 0.6, 575, o_bot - 0.4, f'{OUT}/{fn}', neutral=True)
                qo_img[k] = fn
                stats['oimg'] += 1
            elif not txt:
                stats['empty_opt'] += 1
        if qo_img:
            q['oi'] = [qo_img.get(k) for k in range(4)]
        cur['questions'].append(q)

print('tests', len(tests), [len(t['questions']) for t in tests])
print(stats)

os.makedirs(f'{OUT}/data', exist_ok=True)
manifest = []
for idx, (t, m) in enumerate(zip(tests, metas), start=1):
    d, mo, y, t1, t2 = m
    date = f'{int(d)} {MONTHS[int(mo) - 1]} {y}'
    title = f'Mock Test {idx}'
    sub = f'RRB JE CBT-1 · {date} · {t1} shift'
    doc = dict(id=idx, title=title, subtitle=sub, date=date, time=f'{t1} - {t2}',
               duration=90, correct=1, negative=1 / 3, questions=t['questions'])
    json.dump(doc, open(f'{OUT}/data/test_{idx}.json', 'w', encoding='utf8'), ensure_ascii=False, separators=(',', ':'))
    manifest.append(dict(id=idx, title=title, subtitle=sub, date=date, time=f'{t1} - {t2}',
                         count=len(t['questions']), duration=90))
json.dump(manifest, open(f'{OUT}/data/manifest.json', 'w', encoding='utf8'), ensure_ascii=False, indent=1)
print(json.dumps(manifest[:2], ensure_ascii=False))
