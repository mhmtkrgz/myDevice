"use client";

import { useState, useRef, useEffect, useCallback } from "react";
import { toPng } from "html-to-image";

// ─── Device Types ─────────────────────────────────────────────────────────────

type Device = "iphone" | "ipad";

// ─── Canvas & Export Sizes ────────────────────────────────────────────────────

const IPHONE_W = 1320;
const IPHONE_H = 2868;

const IPAD_W = 2064;
const IPAD_H = 2752;

const IPHONE_SIZES = [
  { label: '6.9"  1320×2868', w: 1320, h: 2868 },
  { label: '6.5"  1284×2778', w: 1284, h: 2778 },
  { label: '6.3"  1206×2622', w: 1206, h: 2622 },
  { label: '6.1"  1125×2436', w: 1125, h: 2436 },
] as const;

const IPAD_SIZES = [
  { label: '13" iPad  2064×2752', w: 2064, h: 2752 },
  { label: '12.9" iPad Pro  2048×2732', w: 2048, h: 2732 },
] as const;

type ExportSize = { label: string; w: number; h: number };

function canvasForDevice(d: Device) {
  return d === "iphone" ? { w: IPHONE_W, h: IPHONE_H } : { w: IPAD_W, h: IPAD_H };
}

function sizesForDevice(d: Device): readonly ExportSize[] {
  return d === "iphone" ? IPHONE_SIZES : IPAD_SIZES;
}

// ─── Locales & Copy ───────────────────────────────────────────────────────────

const LOCALES = ["en", "tr", "de"] as const;
type Locale = (typeof LOCALES)[number];

const LOCALE_LABELS: Record<Locale, string> = { en: "EN", tr: "TR", de: "DE" };

type SlideCopy = { lines: string[]; topOffset?: number };

type SlideConfig = {
  id: string;
  label: string;
  filename: string;
  screenshotFile: string;
  copy: Record<Locale, SlideCopy>;
};

// ─── iPhone Slides ────────────────────────────────────────────────────────────

const IPHONE_SLIDES: SlideConfig[] = [
  {
    id: "iphone-1",
    label: "Copy Identifiers",
    filename: "01-copy-identifiers",
    screenshotFile: "1.png",
    copy: {
      en: { lines: ["COPY", "DEVICE", "IDENTIFIERS", "INSTANTLY"] },
      tr: { lines: ["CİHAZ", "KİMLİKLERİNİ", "ANINDA", "KOPYALA"] },
      de: { lines: ["GERÄTE-IDS", "SOFORT", "KOPIEREN"], topOffset: IPHONE_H * 0.072 },
    },
  },
  {
    id: "iphone-2",
    label: "Diagnose Network",
    filename: "02-diagnose-network",
    screenshotFile: "2.png",
    copy: {
      en: { lines: ["DIAGNOSE", "NETWORK & SIM", "STATUS"], topOffset: IPHONE_H * 0.072 },
      tr: { lines: ["AĞ VE SIM", "DURUMUNU", "TEŞHİS ET"], topOffset: IPHONE_H * 0.072 },
      de: { lines: ["NETZWERK- &", "SIM-STATUS", "PRÜFEN"], topOffset: IPHONE_H * 0.072 },
    },
  },
  {
    id: "iphone-3",
    label: "Device Stats",
    filename: "03-device-stats",
    screenshotFile: "3.png",
    copy: {
      en: { lines: ["INSPECT", "YOUR FULL", "DEVICE STATS"], topOffset: IPHONE_H * 0.072 },
      tr: { lines: ["TÜM CİHAZ", "İSTATİSTİKLERİNİ", "İNCELE"], topOffset: IPHONE_H * 0.072 },
      de: { lines: ["ALLE GERÄTE-", "INFOS AUF", "EINEN BLICK"], topOffset: IPHONE_H * 0.072 },
    },
  },
];

// ─── iPad Slides ──────────────────────────────────────────────────────────────

const IPAD_SLIDES: SlideConfig[] = [
  {
    id: "ipad-1",
    label: "Copy Identifiers",
    filename: "01-copy-identifiers",
    screenshotFile: "1.png",
    copy: {
      en: { lines: ["COPY", "DEVICE", "IDENTIFIERS", "INSTANTLY"] },
      tr: { lines: ["CİHAZ", "KİMLİKLERİNİ", "ANINDA", "KOPYALA"] },
      de: { lines: ["GERÄTE-IDS", "SOFORT", "KOPIEREN"], topOffset: IPAD_H * 0.072 },
    },
  },
  {
    id: "ipad-2",
    label: "Diagnose Network",
    filename: "02-diagnose-network",
    screenshotFile: "2.png",
    copy: {
      en: { lines: ["DIAGNOSE", "NETWORK & SIM", "STATUS"], topOffset: IPAD_H * 0.072 },
      tr: { lines: ["AĞ VE SIM", "DURUMUNU", "TEŞHİS ET"], topOffset: IPAD_H * 0.072 },
      de: { lines: ["NETZWERK- &", "SIM-STATUS", "PRÜFEN"], topOffset: IPAD_H * 0.072 },
    },
  },
];

function slidesForDevice(d: Device): SlideConfig[] {
  return d === "iphone" ? IPHONE_SLIDES : IPAD_SLIDES;
}

// ─── Phone Mockup Measurements ────────────────────────────────────────────────

const MK_W = 1022;
const MK_H = 2082;
const SC_L = (52 / MK_W) * 100;
const SC_T = (46 / MK_H) * 100;
const SC_W = (918 / MK_W) * 100;
const SC_H = (1990 / MK_H) * 100;
const SC_RX = (126 / 918) * 100;
const SC_RY = (126 / 1990) * 100;

// ─── Design Tokens ────────────────────────────────────────────────────────────

const BG_TOP = "#1C1B2E";
const BG_BOT = "#1A1828";
const GLOW_COLOR = "#2D5BE3";
const FONT =
  "-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Helvetica Neue', sans-serif";

// ─── Image Preloading ─────────────────────────────────────────────────────────

const IMAGE_PATHS = [
  "/mockup.png",
  "/app-icon.png",
  ...LOCALES.flatMap((l) => [
    `/screenshots/${l}/1.png`,
    `/screenshots/${l}/2.png`,
    `/screenshots/${l}/3.png`,
    `/screenshots-ipad/${l}/1.png`,
    `/screenshots-ipad/${l}/2.png`,
  ]),
];

const imageCache: Record<string, string> = {};

async function preloadAllImages() {
  await Promise.all(
    IMAGE_PATHS.map(async (path) => {
      const resp = await fetch(path);
      const blob = await resp.blob();
      const dataUrl = await new Promise<string>((resolve) => {
        const reader = new FileReader();
        reader.onloadend = () => resolve(reader.result as string);
        reader.readAsDataURL(blob);
      });
      imageCache[path] = dataUrl;
    })
  );
}

function img(path: string): string {
  return imageCache[path] ?? path;
}

// ─── Phone Component (PNG Mockup) ─────────────────────────────────────────────

function Phone({
  src,
  alt,
  style,
}: {
  src: string;
  alt: string;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "absolute",
        aspectRatio: `${MK_W}/${MK_H}`,
        ...style,
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: "-15%",
          background: `radial-gradient(ellipse at 50% 60%, ${GLOW_COLOR}30 0%, transparent 68%)`,
          pointerEvents: "none",
          zIndex: 0,
        }}
      />
      <img
        src={img("/mockup.png")}
        alt=""
        draggable={false}
        style={{
          display: "block",
          width: "100%",
          height: "100%",
          position: "relative",
          zIndex: 1,
        }}
      />
      <div
        style={{
          position: "absolute",
          left: `${SC_L}%`,
          top: `${SC_T}%`,
          width: `${SC_W}%`,
          height: `${SC_H}%`,
          borderRadius: `${SC_RX}% / ${SC_RY}%`,
          overflow: "hidden",
          zIndex: 2,
        }}
      >
        <img
          src={img(src)}
          alt={alt}
          draggable={false}
          style={{
            display: "block",
            width: "100%",
            height: "100%",
            objectFit: "cover",
            objectPosition: "top",
          }}
        />
      </div>
    </div>
  );
}

// ─── iPad Component (CSS-Only Frame) ──────────────────────────────────────────

function IPad({
  src,
  alt,
  style,
}: {
  src: string;
  alt: string;
  style?: React.CSSProperties;
}) {
  return (
    <div
      style={{
        position: "absolute",
        aspectRatio: "770/1000",
        ...style,
      }}
    >
      {/* Glow behind iPad */}
      <div
        style={{
          position: "absolute",
          inset: "-12%",
          background: `radial-gradient(ellipse at 50% 55%, ${GLOW_COLOR}28 0%, transparent 65%)`,
          pointerEvents: "none",
          zIndex: 0,
        }}
      />
      <div
        style={{
          width: "100%",
          height: "100%",
          borderRadius: "5% / 3.6%",
          background: "linear-gradient(180deg, #2C2C2E 0%, #1C1C1E 100%)",
          position: "relative",
          overflow: "hidden",
          boxShadow:
            "inset 0 0 0 1px rgba(255,255,255,0.1), 0 8px 40px rgba(0,0,0,0.6)",
          zIndex: 1,
        }}
      >
        {/* Front camera dot */}
        <div
          style={{
            position: "absolute",
            top: "1.2%",
            left: "50%",
            transform: "translateX(-50%)",
            width: "0.9%",
            height: "0.65%",
            borderRadius: "50%",
            background: "#111113",
            border: "1px solid rgba(255,255,255,0.08)",
            zIndex: 20,
          }}
        />
        {/* Bezel edge highlight */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            borderRadius: "5% / 3.6%",
            border: "1px solid rgba(255,255,255,0.06)",
            pointerEvents: "none",
            zIndex: 15,
          }}
        />
        {/* Screen area */}
        <div
          style={{
            position: "absolute",
            left: "4%",
            top: "2.8%",
            width: "92%",
            height: "94.4%",
            borderRadius: "2.2% / 1.6%",
            overflow: "hidden",
            background: "#000",
          }}
        >
          <img
            src={img(src)}
            alt={alt}
            draggable={false}
            style={{
              display: "block",
              width: "100%",
              height: "100%",
              objectFit: "cover",
              objectPosition: "top",
            }}
          />
        </div>
      </div>
    </div>
  );
}

// ─── Slide Components ─────────────────────────────────────────────────────────

function SlideBase({
  children,
  canvasW,
  canvasH,
}: {
  children: React.ReactNode;
  canvasW: number;
  canvasH: number;
}) {
  return (
    <div
      style={{
        width: canvasW,
        height: canvasH,
        position: "relative",
        overflow: "hidden",
        background: `linear-gradient(170deg, ${BG_TOP} 0%, ${BG_BOT} 100%)`,
        fontFamily: FONT,
      }}
    >
      <div
        style={{
          position: "absolute",
          top: 0,
          left: "50%",
          transform: "translateX(-50%)",
          width: "120%",
          height: "45%",
          background:
            "radial-gradient(ellipse at 50% 0%, #0D0C1A60 0%, transparent 70%)",
          pointerEvents: "none",
          zIndex: 0,
        }}
      />
      {children}
    </div>
  );
}

function Headline({
  lines,
  topOffset,
  canvasW,
  canvasH,
}: {
  lines: string[];
  topOffset?: number;
  canvasW: number;
  canvasH: number;
}) {
  const fontSize = canvasW * 0.115;
  return (
    <div
      style={{
        position: "absolute",
        top: topOffset ?? canvasH * 0.048,
        left: 0,
        right: 0,
        textAlign: "center",
        zIndex: 10,
        padding: `0 ${canvasW * 0.06}px`,
      }}
    >
      {lines.map((line, i) => (
        <div
          key={i}
          style={{
            color: "#FFFFFF",
            fontSize,
            fontWeight: 900,
            lineHeight: 1.02,
            letterSpacing: "-0.025em",
            textTransform: "uppercase",
            display: "block",
          }}
        >
          {line}
        </div>
      ))}
    </div>
  );
}

function IPhoneSlide({
  config,
  locale,
}: {
  config: SlideConfig;
  locale: Locale;
}) {
  const copy = config.copy[locale];
  const src = `/screenshots/${locale}/${config.screenshotFile}`;
  return (
    <SlideBase canvasW={IPHONE_W} canvasH={IPHONE_H}>
      <Headline
        lines={copy.lines}
        topOffset={copy.topOffset}
        canvasW={IPHONE_W}
        canvasH={IPHONE_H}
      />
      <Phone
        src={src}
        alt={config.label}
        style={{
          width: "76%",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(9%)",
        }}
      />
    </SlideBase>
  );
}

function IPadSlide({
  config,
  locale,
}: {
  config: SlideConfig;
  locale: Locale;
}) {
  const copy = config.copy[locale];
  const src = `/screenshots-ipad/${locale}/${config.screenshotFile}`;
  return (
    <SlideBase canvasW={IPAD_W} canvasH={IPAD_H}>
      <Headline
        lines={copy.lines}
        topOffset={copy.topOffset}
        canvasW={IPAD_W}
        canvasH={IPAD_H}
      />
      <IPad
        src={src}
        alt={config.label}
        style={{
          width: "66%",
          bottom: 0,
          left: "50%",
          transform: "translateX(-50%) translateY(7%)",
        }}
      />
    </SlideBase>
  );
}

// ─── Preview Card ─────────────────────────────────────────────────────────────

function PreviewCard({
  config,
  locale,
  device,
  index,
  onExport,
  exporting,
}: {
  config: SlideConfig;
  locale: Locale;
  device: Device;
  index: number;
  onExport: () => void;
  exporting: boolean;
}) {
  const wrapperRef = useRef<HTMLDivElement>(null);
  const [scale, setScale] = useState(0.25);
  const { w: canvasW, h: canvasH } = canvasForDevice(device);

  useEffect(() => {
    const el = wrapperRef.current;
    if (!el) return;
    const obs = new ResizeObserver(([entry]) => {
      setScale(entry.contentRect.width / canvasW);
    });
    obs.observe(el);
    return () => obs.disconnect();
  }, [canvasW]);

  const SlideComponent = device === "iphone" ? IPhoneSlide : IPadSlide;

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
      <div
        ref={wrapperRef}
        style={{
          width: "100%",
          aspectRatio: `${canvasW}/${canvasH}`,
          overflow: "hidden",
          borderRadius: 12,
          boxShadow: "0 4px 32px rgba(0,0,0,0.6)",
          cursor: "pointer",
        }}
        onClick={onExport}
        title="Click to export"
      >
        <div
          style={{
            width: canvasW,
            height: canvasH,
            transformOrigin: "top left",
            transform: `scale(${scale})`,
            pointerEvents: "none",
          }}
        >
          <SlideComponent config={config} locale={locale} />
        </div>
      </div>
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
        }}
      >
        <span style={{ color: "#888", fontSize: 13, fontFamily: FONT }}>
          {String(index + 1).padStart(2, "0")} — {config.label}
        </span>
        <button
          onClick={onExport}
          disabled={exporting}
          style={{
            background: exporting ? "#333" : "#2D5BE3",
            color: "#fff",
            border: "none",
            borderRadius: 6,
            padding: "5px 12px",
            fontSize: 12,
            fontWeight: 600,
            cursor: exporting ? "not-allowed" : "pointer",
            fontFamily: FONT,
          }}
        >
          {exporting ? "Exporting…" : "Export"}
        </button>
      </div>
    </div>
  );
}

// ─── Resize Helper ────────────────────────────────────────────────────────────

async function resizeDataUrl(
  dataUrl: string,
  targetW: number,
  targetH: number
): Promise<string> {
  return new Promise((resolve) => {
    const image = new Image();
    image.onload = () => {
      const canvas = document.createElement("canvas");
      canvas.width = targetW;
      canvas.height = targetH;
      const ctx = canvas.getContext("2d")!;
      ctx.drawImage(image, 0, 0, targetW, targetH);
      resolve(canvas.toDataURL("image/png"));
    };
    image.src = dataUrl;
  });
}

// ─── Main Page ────────────────────────────────────────────────────────────────

export default function ScreenshotsPage() {
  const [ready, setReady] = useState(false);
  const [device, setDevice] = useState<Device>("iphone");
  const [locale, setLocale] = useState<Locale>("en");
  const [exportSize, setExportSize] = useState<ExportSize>(IPHONE_SIZES[0]);
  const [exportingIndex, setExportingIndex] = useState<number | null>(null);
  const [exportingAll, setExportingAll] = useState(false);

  const exportRefs = useRef<(HTMLDivElement | null)[]>([]);

  const slides = slidesForDevice(device);
  const sizes = sizesForDevice(device);
  const { w: canvasW, h: canvasH } = canvasForDevice(device);

  useEffect(() => {
    preloadAllImages().then(() => setReady(true));
  }, []);

  // Reset export size when switching device
  useEffect(() => {
    setExportSize(sizesForDevice(device)[0]);
  }, [device]);

  const captureSlide = useCallback(
    async (index: number, cw: number, ch: number): Promise<string> => {
      const el = exportRefs.current[index];
      if (!el) throw new Error("ref not found");

      el.style.left = "0px";
      el.style.top = "0px";
      el.style.opacity = "1";
      el.style.zIndex = "-1";

      const opts = { width: cw, height: ch, pixelRatio: 1, cacheBust: true };

      await toPng(el, opts);
      const dataUrl = await toPng(el, opts);

      el.style.left = "-9999px";
      el.style.top = "0px";
      el.style.opacity = "";
      el.style.zIndex = "";

      return dataUrl;
    },
    []
  );

  const downloadPng = useCallback(
    async (
      index: number,
      dataUrl: string,
      loc: Locale,
      dev: Device,
      size: ExportSize
    ) => {
      const slideConfigs = slidesForDevice(dev);
      const config = slideConfigs[index];
      const { w: cw, h: ch } = canvasForDevice(dev);
      let finalUrl = dataUrl;
      if (size.w !== cw || size.h !== ch) {
        finalUrl = await resizeDataUrl(dataUrl, size.w, size.h);
      }
      const link = document.createElement("a");
      link.download = `${config.filename}-${loc}-${dev}-${size.w}x${size.h}.png`;
      link.href = finalUrl;
      link.click();
    },
    []
  );

  const handleExportOne = useCallback(
    async (index: number) => {
      if (exportingIndex !== null || exportingAll) return;
      setExportingIndex(index);
      try {
        const dataUrl = await captureSlide(index, canvasW, canvasH);
        await downloadPng(index, dataUrl, locale, device, exportSize);
      } finally {
        setExportingIndex(null);
      }
    },
    [
      exportingIndex,
      exportingAll,
      captureSlide,
      downloadPng,
      locale,
      device,
      exportSize,
      canvasW,
      canvasH,
    ]
  );

  const handleExportCurrent = useCallback(async () => {
    if (exportingIndex !== null || exportingAll) return;
    setExportingAll(true);
    try {
      for (let i = 0; i < slides.length; i++) {
        setExportingIndex(i);
        const dataUrl = await captureSlide(i, canvasW, canvasH);
        await downloadPng(i, dataUrl, locale, device, exportSize);
        await new Promise((r) => setTimeout(r, 300));
      }
    } finally {
      setExportingIndex(null);
      setExportingAll(false);
    }
  }, [
    exportingIndex,
    exportingAll,
    captureSlide,
    downloadPng,
    locale,
    device,
    exportSize,
    slides,
    canvasW,
    canvasH,
  ]);

  const handleExportAllLocales = useCallback(async () => {
    if (exportingIndex !== null || exportingAll) return;
    setExportingAll(true);
    try {
      for (const loc of LOCALES) {
        setLocale(loc);
        await new Promise((r) => setTimeout(r, 400));
        for (let i = 0; i < slides.length; i++) {
          setExportingIndex(i);
          await new Promise((r) => setTimeout(r, 200));
          const dataUrl = await captureSlide(i, canvasW, canvasH);
          await downloadPng(i, dataUrl, loc, device, exportSize);
          await new Promise((r) => setTimeout(r, 300));
        }
      }
    } finally {
      setExportingIndex(null);
      setExportingAll(false);
    }
  }, [
    exportingIndex,
    exportingAll,
    captureSlide,
    downloadPng,
    device,
    exportSize,
    slides,
    canvasW,
    canvasH,
  ]);

  const gridCols = device === "iphone" ? 3 : 2;
  const SlideComponent = device === "iphone" ? IPhoneSlide : IPadSlide;

  if (!ready) {
    return (
      <div
        style={{
          minHeight: "100vh",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          color: "#666",
          fontFamily: FONT,
          fontSize: 16,
        }}
      >
        Loading images…
      </div>
    );
  }

  return (
    <div style={{ minHeight: "100vh", padding: "32px 24px", fontFamily: FONT }}>
      {/* Toolbar */}
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 12,
          marginBottom: 32,
          flexWrap: "wrap",
        }}
      >
        <span
          style={{ color: "#fff", fontWeight: 700, fontSize: 16, marginRight: 8 }}
        >
          My Device — Screenshots
        </span>

        {/* Device toggle */}
        <div
          style={{
            display: "flex",
            background: "#222",
            borderRadius: 6,
            overflow: "hidden",
            border: "1px solid #444",
          }}
        >
          {(["iphone", "ipad"] as Device[]).map((d) => (
            <button
              key={d}
              onClick={() => setDevice(d)}
              style={{
                background: device === d ? "#555" : "transparent",
                color: "#fff",
                border: "none",
                padding: "6px 14px",
                fontSize: 13,
                fontWeight: device === d ? 700 : 400,
                cursor: "pointer",
                fontFamily: FONT,
              }}
            >
              {d === "iphone" ? "iPhone" : "iPad"}
            </button>
          ))}
        </div>

        {/* Locale tabs */}
        <div
          style={{
            display: "flex",
            background: "#222",
            borderRadius: 6,
            overflow: "hidden",
            border: "1px solid #444",
          }}
        >
          {LOCALES.map((l) => (
            <button
              key={l}
              onClick={() => setLocale(l)}
              style={{
                background: locale === l ? "#2D5BE3" : "transparent",
                color: "#fff",
                border: "none",
                padding: "6px 14px",
                fontSize: 13,
                fontWeight: locale === l ? 700 : 400,
                cursor: "pointer",
                fontFamily: FONT,
              }}
            >
              {LOCALE_LABELS[l]}
            </button>
          ))}
        </div>

        {/* Size dropdown */}
        <select
          value={exportSize.label}
          onChange={(e) => {
            const found = sizes.find((s) => s.label === e.target.value);
            if (found) setExportSize(found);
          }}
          style={{
            background: "#222",
            color: "#fff",
            border: "1px solid #444",
            borderRadius: 6,
            padding: "6px 10px",
            fontSize: 13,
            fontFamily: FONT,
            cursor: "pointer",
          }}
        >
          {sizes.map((s) => (
            <option key={s.label} value={s.label}>
              {s.label}
            </option>
          ))}
        </select>

        {/* Export current locale */}
        <button
          onClick={handleExportCurrent}
          disabled={exportingAll || exportingIndex !== null}
          style={{
            background: exportingAll ? "#333" : "#fff",
            color: exportingAll ? "#888" : "#000",
            border: "none",
            borderRadius: 6,
            padding: "7px 16px",
            fontSize: 13,
            fontWeight: 700,
            cursor: exportingAll ? "not-allowed" : "pointer",
            fontFamily: FONT,
          }}
        >
          {exportingAll ? "Exporting…" : `Export ${LOCALE_LABELS[locale]}`}
        </button>

        {/* Export all locales */}
        <button
          onClick={handleExportAllLocales}
          disabled={exportingAll || exportingIndex !== null}
          style={{
            background: exportingAll ? "#333" : "#2D5BE3",
            color: "#fff",
            border: "none",
            borderRadius: 6,
            padding: "7px 16px",
            fontSize: 13,
            fontWeight: 700,
            cursor: exportingAll ? "not-allowed" : "pointer",
            fontFamily: FONT,
          }}
        >
          Export All Locales
        </button>
      </div>

      {/* Preview grid */}
      <div
        style={{
          display: "grid",
          gridTemplateColumns: `repeat(${gridCols}, 1fr)`,
          gap: 24,
          maxWidth: device === "iphone" ? 1100 : 900,
        }}
      >
        {slides.map((config, i) => (
          <PreviewCard
            key={`${config.id}-${locale}`}
            config={config}
            locale={locale}
            device={device}
            index={i}
            onExport={() => handleExportOne(i)}
            exporting={exportingIndex === i}
          />
        ))}
      </div>

      {/* Offscreen export containers */}
      {slides.map((config, i) => (
        <div
          key={`export-${config.id}-${locale}`}
          ref={(el) => {
            exportRefs.current[i] = el;
          }}
          style={{
            position: "fixed",
            top: 0,
            left: "-9999px",
            width: canvasW,
            height: canvasH,
            zIndex: -1,
            fontFamily: FONT,
          }}
        >
          <SlideComponent config={config} locale={locale} />
        </div>
      ))}
    </div>
  );
}
