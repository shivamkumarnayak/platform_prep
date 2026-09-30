import re, html, json, subprocess, pickle, os
import pdfplumber

PDF = '/mnt/user-data/uploads/RRB_JE_CBT_1_Key_Hindi.pdf'
BBOX = '/home/claude/bbox.html'

if not os.path.exists(BBOX):
    subprocess.run(['pdftotext', '-bbox', PDF, BBOX], check=True)

# ---------- poppler words (good Hindi decoding) ----------
raw = open(BBOX, encoding='utf8').read()
page_chunks = raw.split('<page ')[1:]
wre = re.compile(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</word>', re.S)
poppler = []
for ch in page_chunks:
    ws = []
    for x0, y0, x1, y1, t in wre.findall(ch):
        x0, y0, x1, y1 = map(float, (x0, y0, x1, y1))
        if (y1 - y0) > 20:      # giant purple watermark glyphs
            continue
        ws.append(dict(x0=x0, y0=y0, x1=x1, y1=y1, t=html.unescape(t)))
    poppler.append(ws)

# ---------- pdfplumber geometry ----------
def is_green(c):
    return c is not None and len(c) == 3 and c[1] > c[0] + 0.3 and c[1] > c[2] + 0.3

def is_red(c):
    return c is not None and len(c) == 3 and c[0] > c[1] + 0.3 and c[0] > c[2] + 0.3

pdf = pdfplumber.open(PDF)
pages = []
for pi, pg in enumerate(pdf.pages):
    words = pg.extract_words(extra_attrs=['non_stroking_color', 'size'])
    anchors = []
    for w in words:
        if w['x0'] < 45 and re.fullmatch(r'Q\.\d+', w['text']):
            anchors.append(dict(q=int(w['text'][2:]), top=w['top']))
    anchors.sort(key=lambda a: a['top'])
    toks = []
    for w in words:
        if 72 <= w['x0'] <= 90 and re.fullmatch(r'[1-4]\.', w['text']) and w['size'] < 12:
            col = w['non_stroking_color']
            toks.append(dict(n=int(w['text'][0]), top=w['top'], bottom=w['bottom'], x0=w['x0'],
                             green=is_green(col), red=is_red(col)))
    toks.sort(key=lambda t: t['top'])
    ans = [dict(top=w['top']) for w in words if w['x0'] < 50 and w['text'] == 'Ans']
    pages.append(dict(anchors=anchors, toks=toks, ans=ans, H=pg.height, W=pg.width))

pickle.dump(dict(poppler=poppler, pages=pages), open('/home/claude/stage1.pkl', 'wb'))

# ---------- quick diagnostics ----------
tot = sum(len(p['anchors']) for p in pages)
print('pages', len(pages), 'anchors', tot)
bad = 0
for pi, p in enumerate(pages):
    a = p['anchors']
    for i, an in enumerate(a):
        top = an['top'] - 6
        bot = a[i + 1]['top'] - 6 if i + 1 < len(a) else p['H']
        tk = [t for t in p['toks'] if top <= t['top'] < bot]
        ns = [t['n'] for t in tk]
        greens = [t['n'] for t in tk if t['green']]
        if ns != [1, 2, 3, 4] or len(greens) != 1:
            bad += 1
            print('page', pi + 1, 'Q', an['q'], 'opts', ns, 'green', greens)
print('bad blocks', bad)
