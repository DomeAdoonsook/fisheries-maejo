# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the project

Double-click `เปิดเว็บ.bat` or run:
```
python -m http.server 8000
```
Then open http://localhost:8000 — **must** be served via HTTP, not file:// (Three.js GLB loader requires it).

## Architecture

Single-file app: everything is in `index.html` (~2500+ lines). No build step, no npm, no bundler.

### Pages
| Page | Description |
|------|-------------|
| Page 0 | แผนที่โจรสลัด (pirate map) — หน้าแรก |
| Page 2 | อาคารสำนักงาน — รายละเอียดอาคาร + floor hotspots |
| Page 3 | ISLAND PERSONNEL — ประเสริฐ ประสงค์ผล (พี่นัส) นักวิชาการประมง |
| Person page | โปรไฟล์บุคลากร (z-index 90, เปิดจาก pin บน 2.glb) |

### 3D Views (Three.js r160 via importmap)
- **`2.glb`** — อาคารคณะ, autoRotate, มี pin 6 อัน (labels 1–6), pin index 4 คลิกไป Page 2
- **`3D-1.glb`** — โรงเรือนเพาะเลี้ยง, swing ±45° ช้า (swingSpeed=0.015), pin เดียวไม่มีเลข คลิกไป Page 3

### Key global functions (ES module → window)
```js
window.loadGlbModel(glbFile, onLoaded)  // โหลด GLB + callback หลังโมเดลอยู่ใน scene
window.setRenderActive(bool)            // เปิด/ปิด renderer (ปิดตอนอยู่ Page 0/2/3)
window.setPinsEnabled(bool)             // แสดง/ซ่อน pin 6 อัน (เฉพาะ 2.glb)
window.setPin3D1Enabled(bool)           // แสดง/ซ่อน pin ของ 3D-1.glb
```

### Page transition pattern
ทุก transition ใช้ `#fade-overlay` (z-index 50) ปิดหน้าจอก่อนเสมอ:
1. `overlay.classList.add('visible')` → จอดำ
2. `setTimeout(..., 650)` → สลับ page, ปิด/เปิด renderer
3. `overlay.classList.remove('visible')` → fade out

**อย่า** remove overlay ก่อนที่ GLB โหลดเสร็จ — ใช้ `onLoaded` callback แทน

### Pin system
- `pinPoints[]` — Vector3 ตำแหน่ง 3D ของ pin 6 อัน (สำหรับ 2.glb)
- `pin3D1Point` — Vector3 ตำแหน่ง pin ของ 3D-1.glb (ล็อคที่ x:19.4, z:-54.9)
- `updatePins()` — project 3D→2D ทุก frame ใน animate loop

### Person page data (JS objects ใน script ท้ายไฟล์)
- `expertises{}` — ความเชี่ยวชาญแต่ละคน (typewriter effect)
- `powerLevels{}` — ค่า s1/s2/s3 สำหรับ bar animation
- `lockedPins{}` — ตำแหน่ง x/y (%) ของ mark แดงบนแผนที่ชั้น 1
- `supportStaffLabels[]` — รายชื่อสายสนับสนุน (label bar ต่างจากสายวิชาการ)

### Image/asset naming
- `1.png`–`27.png` — รูปบุคลากร/ประกอบ
- `8-2.png`, `9-2.png`, `*-1.png` — portrait สำหรับ person page
- `26-2.png` — แผนที่ชั้น 1 อาคาร (ใช้ใน map frame)
- `2.glb`, `3D-1.glb` — โมเดล 3D หลัก (ไม่ได้เก็บใน git)

## Important constraints
- GLB files ถูก exclude ใน `.gitignore` — ต้องมีไฟล์อยู่ใน folder จึงจะรัน 3D ได้
- `renderActive` flag — renderer หยุดทำงานตอนอยู่นอก 3D view เพื่อประหยัด CPU
- Pin ของ 3D-1.glb และ pin 6 อันของ 2.glb เป็นคนละ element กัน อย่าสับสน
