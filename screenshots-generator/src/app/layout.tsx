import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "My Device — App Store Screenshots",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body
        style={{
          margin: 0,
          background: "#111",
          fontFamily:
            "-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Helvetica Neue', sans-serif",
        }}
      >
        {children}
      </body>
    </html>
  );
}
