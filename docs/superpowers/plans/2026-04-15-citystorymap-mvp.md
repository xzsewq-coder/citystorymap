# CityStoryMap MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 교토를 배경으로 한 테마별 스토리 탐험 웹앱 MVP 구현 (홈 캐러셀 + 테마 상세 카드/지도뷰 + 글로벌 지도)

**Architecture:** Next.js App Router 기반 단일 프로젝트. 서버 컴포넌트에서 Supabase 직접 호출, 인터랙션이 필요한 컴포넌트만 클라이언트 컴포넌트로 분리. Google Maps는 클라이언트 전용.

**Tech Stack:** Next.js 14 (App Router), TypeScript, Tailwind CSS, Supabase (PostgreSQL), Google Maps JS API (`@vis.gl/react-google-maps`), Vercel 배포

---

## 파일 구조

```
citystorymap/
├── app/
│   ├── layout.tsx                  # 루트 레이아웃 (폰트, 메타)
│   ├── page.tsx                    # 홈 (캐러셀 + 스토리 리스트)
│   ├── theme/[themeId]/
│   │   └── page.tsx                # 테마 상세 (카드뷰/지도뷰)
│   └── map/
│       └── page.tsx                # 글로벌 지도 탭
├── components/
│   ├── layout/
│   │   ├── TopNav.tsx              # 상단 네비 (로고 + 도시명)
│   │   └── BottomTabs.tsx          # 하단 탭바 (스토리/지도)
│   ├── home/
│   │   ├── HeroCarousel.tsx        # 자동 슬라이드 히어로 (client)
│   │   └── StoryList.tsx           # 전체 테마 리스트
│   ├── theme/
│   │   ├── ThemeHero.tsx           # 테마 상세 히어로 헤더
│   │   ├── ViewTabs.tsx            # 카드뷰/지도뷰 탭 전환 (client)
│   │   ├── PlaceCard.tsx           # 개별 장소 카드
│   │   ├── CardView.tsx            # 장소 카드 목록
│   │   └── ThemeMapView.tsx        # 테마 지도뷰 (client)
│   └── map/
│       └── GlobalMapView.tsx       # 글로벌 지도 (client)
├── lib/
│   ├── supabase/
│   │   ├── client.ts               # 브라우저용 Supabase client
│   │   └── server.ts               # 서버 컴포넌트용 Supabase client
│   └── types.ts                    # 공유 TypeScript 타입
└── supabase/
    ├── schema.sql                  # 테이블 DDL
    └── seed.sql                    # 교토 샘플 데이터
```

---

## Task 1: 프로젝트 초기화

**Files:**
- Create: `package.json` (자동 생성)
- Create: `tailwind.config.ts`
- Create: `.env.local`

- [ ] **Step 1: Next.js 프로젝트 생성**

```bash
cd C:/Users/xzsew/projects
npx create-next-app@latest citystorymap \
  --typescript \
  --tailwind \
  --app \
  --src-dir=false \
  --import-alias="@/*"
cd citystorymap
```

- [ ] **Step 2: 의존성 설치**

```bash
npm install @supabase/supabase-js @supabase/ssr @vis.gl/react-google-maps
```

- [ ] **Step 3: `.env.local` 생성**

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_google_maps_api_key
```

> Supabase 프로젝트는 https://supabase.com 에서 생성 후 Settings → API에서 URL과 anon key 복사.
> Google Maps API Key는 Google Cloud Console에서 Maps JavaScript API 활성화 후 발급.

- [ ] **Step 4: 빌드 확인**

```bash
npm run dev
```

Expected: http://localhost:3000 에서 기본 Next.js 페이지 열림

- [ ] **Step 5: 커밋**

```bash
git add .
git commit -m "chore: init Next.js project with Tailwind, Supabase, Google Maps"
```

---

## Task 2: TypeScript 타입 정의

**Files:**
- Create: `lib/types.ts`

- [ ] **Step 1: 타입 작성**

`lib/types.ts`:
```typescript
export type City = {
  id: string
  name_ko: string
  name_en: string
  description: string
}

export type Theme = {
  id: string
  city_id: string
  title: string
  category: string        // '소설' | '애니메이션' | '역사' | '영화'
  year: string            // 예: '1956년'
  hook_text: string
  hero_gradient_from: string   // CSS 색상값, 예: '#1a1020'
  hero_gradient_to: string     // CSS 색상값, 예: '#3d1a0e'
  is_featured: boolean
  featured_order: number | null
  place_count: number     // 계산 필드 (뷰 또는 앱에서 처리)
}

export type Place = {
  id: string
  theme_id: string
  name: string
  emoji: string
  district: string
  story_quote: string
  tags: string[]
  order: number
  lat: number
  lng: number
  card_gradient_from: string
  card_gradient_to: string
}
```

- [ ] **Step 2: 타입 체크**

```bash
npx tsc --noEmit
```

Expected: 에러 없음

- [ ] **Step 3: 커밋**

```bash
git add lib/types.ts
git commit -m "feat: add shared TypeScript types"
```

---

## Task 3: Supabase 스키마 + 시드 데이터

**Files:**
- Create: `supabase/schema.sql`
- Create: `supabase/seed.sql`

- [ ] **Step 1: 스키마 작성**

`supabase/schema.sql`:
```sql
create table cities (
  id uuid primary key default gen_random_uuid(),
  name_ko text not null,
  name_en text not null,
  description text not null
);

create table themes (
  id uuid primary key default gen_random_uuid(),
  city_id uuid references cities(id) on delete cascade,
  title text not null,
  category text not null,
  year text not null,
  hook_text text not null,
  hero_gradient_from text not null default '#1a1020',
  hero_gradient_to text not null default '#3d1a0e',
  is_featured boolean not null default false,
  featured_order int,
  created_at timestamptz default now()
);

create table places (
  id uuid primary key default gen_random_uuid(),
  theme_id uuid references themes(id) on delete cascade,
  name text not null,
  emoji text not null,
  district text not null,
  story_quote text not null,
  tags text[] not null default '{}',
  "order" int not null,
  lat double precision not null,
  lng double precision not null,
  card_gradient_from text not null default '#1a1020',
  card_gradient_to text not null default '#3d1a0e',
  created_at timestamptz default now()
);

-- 테마별 place_count를 효율적으로 가져오는 뷰
create view themes_with_count as
  select t.*, count(p.id)::int as place_count
  from themes t
  left join places p on p.theme_id = t.id
  group by t.id;
```

- [ ] **Step 2: Supabase SQL 편집기에서 스키마 실행**

Supabase 대시보드 → SQL Editor → 위 SQL 붙여넣고 실행

- [ ] **Step 3: 시드 데이터 작성**

`supabase/seed.sql`:
```sql
-- 도시: 교토
insert into cities (id, name_ko, name_en, description) values
  ('00000000-0000-0000-0000-000000000001', '교토', 'Kyoto', '천 년의 고도, 이야기가 쌓인 도시');

-- 테마들
insert into themes (id, city_id, title, category, year, hook_text, hero_gradient_from, hero_gradient_to, is_featured, featured_order) values
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001',
   '미시마 유키오의 금각사 루트', '소설', '1956년',
   '불꽃처럼 살다 간 작가가 바라본 교토의 풍경들을 따라서',
   '#1a1020', '#3d1a0e', true, 1),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001',
   '신센구미가 활약하던 곳', '역사', '막부 말기',
   '교토를 지키려 했던 마지막 무사들의 발자취',
   '#1a1200', '#3a2800', true, 2),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001',
   '사카모토 료마의 마지막 날들', '역사', '메이지 유신',
   '유신의 불꽃이 꺼진 교토, 그가 마지막으로 걸었던 길',
   '#1a0a0a', '#3a1010', true, 3),
  ('10000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001',
   '〈언어의 정원〉 성지순례', '애니메이션', '2013년',
   '빗소리와 함께 기억되는 신카이 마코토의 교토',
   '#0e1a2e', '#1a2e4a', false, null);

-- 장소들 (미시마 유키오 테마)
insert into places (theme_id, name, emoji, district, story_quote, tags, "order", lat, lng, card_gradient_from, card_gradient_to) values
  ('10000000-0000-0000-0000-000000000001', '금각사 (킨카쿠지)', '🏯', '기타야마 · 교토',
   '미조구치가 집착한 그 아름다움. 불꽃보다 더 오래 타오르는 것들에 대하여.',
   array['1950년대', '사원'], 1, 35.0394, 135.7292, '#2a1505', '#6b3412'),
  ('10000000-0000-0000-0000-000000000001', '료안지 석정', '⛩️', '우쿄구 · 교토',
   '작가가 자주 찾아 사색했던 곳. 비어있음과 가득참이 공존하는 정원.',
   array['선사', '정원'], 2, 35.0345, 135.7183, '#081422', '#0f2a42'),
  ('10000000-0000-0000-0000-000000000001', '니조 성', '🏰', '나카쿄구 · 교토',
   '권력의 절정과 몰락이 교차하는 곳. 미조구치가 아름다움의 덧없음을 느꼈던 성.',
   array['성곽', '에도시대'], 3, 35.0142, 135.7480, '#1a1a0a', '#3a3010');
```

- [ ] **Step 4: Supabase SQL 편집기에서 시드 실행**

- [ ] **Step 5: 커밋**

```bash
git add supabase/
git commit -m "feat: add Supabase schema and Kyoto seed data"
```

---

## Task 4: Supabase 클라이언트 설정

**Files:**
- Create: `lib/supabase/client.ts`
- Create: `lib/supabase/server.ts`

- [ ] **Step 1: 브라우저용 클라이언트 작성**

`lib/supabase/client.ts`:
```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

- [ ] **Step 2: 서버 컴포넌트용 클라이언트 작성**

`lib/supabase/server.ts`:
```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() { return cookieStore.getAll() },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {}
        },
      },
    }
  )
}
```

- [ ] **Step 3: 타입 체크**

```bash
npx tsc --noEmit
```

Expected: 에러 없음

- [ ] **Step 4: 커밋**

```bash
git add lib/supabase/
git commit -m "feat: add Supabase server and browser clients"
```

---

## Task 5: Tailwind 디자인 토큰 + 글로벌 스타일

**Files:**
- Modify: `tailwind.config.ts`
- Modify: `app/globals.css`

- [ ] **Step 1: Tailwind config에 디자인 토큰 추가**

`tailwind.config.ts`:
```typescript
import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        surface: '#faf9f6',
        page: '#f5f3ee',
        'page-dark': '#edeae3',
        ink: '#2c2c2c',
        'ink-muted': '#888888',
        'ink-faint': '#bbbbbb',
        accent: '#8b6f4e',
        border: '#ede9e3',
      },
      fontFamily: {
        serif: ['Georgia', 'serif'],
        sans: ['system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}

export default config
```

- [ ] **Step 2: 글로벌 CSS 정리**

`app/globals.css`:
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  body {
    @apply bg-page text-ink font-sans;
  }
}
```

- [ ] **Step 3: 커밋**

```bash
git add tailwind.config.ts app/globals.css
git commit -m "feat: add design tokens to Tailwind config"
```

---

## Task 6: 레이아웃 컴포넌트 (TopNav + BottomTabs)

**Files:**
- Create: `components/layout/TopNav.tsx`
- Create: `components/layout/BottomTabs.tsx`
- Modify: `app/layout.tsx`

- [ ] **Step 1: TopNav 작성**

`components/layout/TopNav.tsx`:
```typescript
export function TopNav() {
  return (
    <nav className="bg-surface border-b border-border px-4 py-3 flex justify-between items-center">
      <span className="font-serif text-xs tracking-widest uppercase text-ink">
        CityStoryMap
      </span>
      <span className="font-sans text-[10px] text-ink-muted tracking-wide">
        📍 교토 Kyoto
      </span>
    </nav>
  )
}
```

- [ ] **Step 2: BottomTabs 작성**

`components/layout/BottomTabs.tsx`:
```typescript
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

export function BottomTabs() {
  const pathname = usePathname()
  const isMap = pathname === '/map'

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-surface border-t border-border flex">
      <Link
        href="/"
        className={`flex-1 flex flex-col items-center py-2 gap-0.5 font-sans text-[8px] tracking-widest uppercase transition-colors ${
          !isMap ? 'text-ink' : 'text-ink-faint'
        }`}
      >
        <span className="text-base">📖</span>
        스토리
      </Link>
      <Link
        href="/map"
        className={`flex-1 flex flex-col items-center py-2 gap-0.5 font-sans text-[8px] tracking-widest uppercase transition-colors ${
          isMap ? 'text-ink' : 'text-ink-faint'
        }`}
      >
        <span className="text-base">🗺️</span>
        지도
      </Link>
    </nav>
  )
}
```

- [ ] **Step 3: 루트 레이아웃에 적용**

`app/layout.tsx`:
```typescript
import type { Metadata } from 'next'
import './globals.css'
import { TopNav } from '@/components/layout/TopNav'
import { BottomTabs } from '@/components/layout/BottomTabs'

export const metadata: Metadata = {
  title: 'CityStoryMap',
  description: '도시를 이야기로 탐험하세요',
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <div className="max-w-sm mx-auto min-h-screen flex flex-col bg-page">
          <TopNav />
          <main className="flex-1 pb-16">
            {children}
          </main>
          <BottomTabs />
        </div>
      </body>
    </html>
  )
}
```

- [ ] **Step 4: 개발 서버에서 확인**

```bash
npm run dev
```

Expected: 상단 네비 + 하단 탭 바가 보임. 탭 클릭 시 URL 변경됨.

- [ ] **Step 5: 커밋**

```bash
git add components/layout/ app/layout.tsx
git commit -m "feat: add TopNav and BottomTabs layout components"
```

---

## Task 7: 홈 — HeroCarousel

**Files:**
- Create: `components/home/HeroCarousel.tsx`

- [ ] **Step 1: HeroCarousel 작성**

`components/home/HeroCarousel.tsx`:
```typescript
'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import type { Theme } from '@/lib/types'

type Props = {
  themes: Theme[]
}

export function HeroCarousel({ themes }: Props) {
  const [current, setCurrent] = useState(0)

  useEffect(() => {
    const timer = setInterval(() => {
      setCurrent((c) => (c + 1) % themes.length)
    }, 3500)
    return () => clearInterval(timer)
  }, [themes.length])

  if (themes.length === 0) return null

  return (
    <div className="relative h-[220px] overflow-hidden">
      {themes.map((theme, i) => (
        <Link
          key={theme.id}
          href={`/theme/${theme.id}`}
          className={`absolute inset-0 flex flex-col justify-end p-5 transition-opacity duration-700 ${
            i === current ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'
          }`}
          style={{
            background: `linear-gradient(160deg, ${theme.hero_gradient_from} 0%, ${theme.hero_gradient_to} 100%)`,
          }}
        >
          {/* 하단 그라디언트 오버레이 */}
          <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent" />

          <div className="relative z-10">
            <p className="font-sans text-[8px] tracking-widest uppercase text-white/65 mb-1">
              {theme.category} · {theme.year}
            </p>
            <h2 className="font-serif text-[17px] italic text-white leading-snug mb-1.5">
              {theme.title}
            </h2>
            <p className="font-sans text-[9.5px] text-white/65 leading-relaxed mb-2.5 line-clamp-2">
              {theme.hook_text}
            </p>
            <div className="flex justify-between items-center">
              <span className="font-sans text-[9px] text-white/50">
                📍 {theme.place_count}곳
              </span>
              <span className="font-sans text-[9px] text-yellow-300/90 tracking-wide uppercase">
                탐험하기 →
              </span>
            </div>
          </div>
        </Link>
      ))}

      {/* 닷 인디케이터 */}
      <div className="absolute bottom-2.5 left-1/2 -translate-x-1/2 flex gap-1.5 z-20">
        {themes.map((_, i) => (
          <button
            key={i}
            onClick={() => setCurrent(i)}
            className={`h-[5px] rounded-full transition-all duration-300 ${
              i === current ? 'w-3.5 bg-white' : 'w-1.5 bg-white/35'
            }`}
            aria-label={`슬라이드 ${i + 1}`}
          />
        ))}
      </div>
    </div>
  )
}
```

- [ ] **Step 2: 커밋**

```bash
git add components/home/HeroCarousel.tsx
git commit -m "feat: add HeroCarousel component with auto-slide"
```

---

## Task 8: 홈 — StoryList

**Files:**
- Create: `components/home/StoryList.tsx`

- [ ] **Step 1: StoryList 작성**

`components/home/StoryList.tsx`:
```typescript
import Link from 'next/link'
import type { Theme } from '@/lib/types'

type Props = {
  themes: Theme[]
}

export function StoryList({ themes }: Props) {
  return (
    <div>
      <div className="flex justify-between items-baseline px-4 py-3 border-b border-border">
        <span className="font-sans text-[8.5px] tracking-widest uppercase text-ink-muted">
          교토의 모든 이야기
        </span>
        <span className="font-sans text-[8.5px] text-accent">
          {themes.length}개
        </span>
      </div>

      {themes.map((theme) => (
        <Link
          key={theme.id}
          href={`/theme/${theme.id}`}
          className="flex items-center gap-3 px-4 py-2.5 border-b border-border/60 hover:bg-surface transition-colors"
        >
          <div
            className="w-10 h-10 rounded-lg flex-shrink-0 flex items-center justify-center text-lg"
            style={{
              background: `linear-gradient(135deg, ${theme.hero_gradient_from}, ${theme.hero_gradient_to})`,
            }}
          >
            {theme.category === '소설' && '📖'}
            {theme.category === '역사' && '⚔️'}
            {theme.category === '애니메이션' && '🌌'}
            {theme.category === '영화' && '🎬'}
          </div>
          <div className="flex-1 min-w-0">
            <p className="font-serif text-[11px] text-ink leading-snug truncate">
              {theme.title}
            </p>
            <p className="font-sans text-[9px] text-ink-faint mt-0.5">
              {theme.category} · {theme.place_count}곳
            </p>
          </div>
          <span className="text-ink-faint text-sm flex-shrink-0">›</span>
        </Link>
      ))}
    </div>
  )
}
```

- [ ] **Step 2: 커밋**

```bash
git add components/home/StoryList.tsx
git commit -m "feat: add StoryList component"
```

---

## Task 9: 홈 페이지 조립

**Files:**
- Modify: `app/page.tsx`

- [ ] **Step 1: 홈 페이지 작성 (서버 컴포넌트)**

`app/page.tsx`:
```typescript
import { createClient } from '@/lib/supabase/server'
import { HeroCarousel } from '@/components/home/HeroCarousel'
import { StoryList } from '@/components/home/StoryList'
import type { Theme } from '@/lib/types'

export default async function HomePage() {
  const supabase = createClient()

  const { data: featuredThemes } = await supabase
    .from('themes_with_count')
    .select('*')
    .eq('is_featured', true)
    .order('featured_order', { ascending: true })

  const { data: allThemes } = await supabase
    .from('themes_with_count')
    .select('*')
    .order('created_at', { ascending: true })

  return (
    <>
      <HeroCarousel themes={(featuredThemes as Theme[]) ?? []} />
      <StoryList themes={(allThemes as Theme[]) ?? []} />
    </>
  )
}
```

- [ ] **Step 2: 개발 서버에서 확인**

```bash
npm run dev
```

Expected: 홈 화면에 캐러셀(3.5초 자동 슬라이드)과 스토리 리스트가 표시됨. Supabase에서 실제 데이터 로드됨.

- [ ] **Step 3: 커밋**

```bash
git add app/page.tsx
git commit -m "feat: home page with carousel and story list from Supabase"
```

---

## Task 10: 테마 상세 — ThemeHero + ViewTabs

**Files:**
- Create: `components/theme/ThemeHero.tsx`
- Create: `components/theme/ViewTabs.tsx`

- [ ] **Step 1: ThemeHero 작성**

`components/theme/ThemeHero.tsx`:
```typescript
import Link from 'next/link'
import type { Theme } from '@/lib/types'

type Props = {
  theme: Theme
}

export function ThemeHero({ theme }: Props) {
  return (
    <div
      className="relative h-[130px] flex flex-col justify-end px-4 py-3.5 overflow-hidden"
      style={{
        background: `linear-gradient(160deg, ${theme.hero_gradient_from} 0%, ${theme.hero_gradient_to} 100%)`,
      }}
    >
      <div className="absolute inset-0 bg-gradient-to-t from-black/65 via-transparent to-transparent" />
      <Link
        href="/"
        className="absolute top-3.5 left-4 font-sans text-[10px] text-white/60 z-10 hover:text-white/90 transition-colors"
      >
        ← 교토
      </Link>
      <div className="relative z-10">
        <p className="font-sans text-[8px] tracking-widest uppercase text-white/55 mb-1">
          📍 {theme.place_count}곳
        </p>
        <h1 className="font-serif text-[17px] italic text-white leading-snug">
          {theme.title}
        </h1>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: ViewTabs 작성**

`components/theme/ViewTabs.tsx`:
```typescript
'use client'

type View = 'card' | 'map'

type Props = {
  view: View
  onChange: (view: View) => void
}

export function ViewTabs({ view, onChange }: Props) {
  return (
    <div className="flex bg-surface border-b border-border">
      {(['card', 'map'] as View[]).map((v) => (
        <button
          key={v}
          onClick={() => onChange(v)}
          className={`flex-1 py-2.5 font-sans text-[10px] tracking-widest uppercase transition-colors border-b-2 ${
            view === v
              ? 'text-ink border-ink'
              : 'text-ink-faint border-transparent'
          }`}
        >
          {v === 'card' ? '카드뷰' : '지도뷰'}
        </button>
      ))}
    </div>
  )
}
```

- [ ] **Step 3: 커밋**

```bash
git add components/theme/
git commit -m "feat: add ThemeHero and ViewTabs components"
```

---

## Task 11: 테마 상세 — PlaceCard + CardView

**Files:**
- Create: `components/theme/PlaceCard.tsx`
- Create: `components/theme/CardView.tsx`

- [ ] **Step 1: PlaceCard 작성**

`components/theme/PlaceCard.tsx`:
```typescript
import type { Place } from '@/lib/types'

type Props = {
  place: Place
  index: number
}

export function PlaceCard({ place, index }: Props) {
  const num = String(index + 1).padStart(2, '0')

  return (
    <div className="rounded-xl overflow-hidden shadow-sm mb-3.5">
      {/* 이미지 영역 */}
      <div
        className="relative h-[120px] flex items-center justify-center overflow-hidden"
        style={{
          background: `linear-gradient(135deg, ${place.card_gradient_from} 0%, ${place.card_gradient_to} 100%)`,
        }}
      >
        {/* 텍스처 패턴 오버레이 */}
        <div
          className="absolute inset-0 opacity-5"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3Csvg width='40' height='40' viewBox='0 0 40 40' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='%23ffffff' fill-opacity='1'%3E%3Cpath d='M0 38.59l2.83-2.83 1.41 1.41L1.41 40H0v-1.41zM0 1.4l2.83 2.83 1.41-1.41L1.41 0H0v1.41zM38.59 40l-2.83-2.83 1.41-1.41L40 38.59V40h-1.41z'/%3E%3C/g%3E%3C/svg%3E")`,
          }}
        />
        {/* 하단 그라디언트 */}
        <div className="absolute bottom-0 left-0 right-0 h-16 bg-gradient-to-t from-black/50 to-transparent z-10" />

        {/* 순번 */}
        <span className="absolute top-2.5 left-3 font-sans text-[8px] tracking-widest text-white/45 z-20">
          {num}
        </span>

        {/* 이모지 */}
        <span className="text-[42px] relative z-10 drop-shadow-lg">{place.emoji}</span>

        {/* 장소명 + 지역 */}
        <div className="absolute bottom-0 left-0 right-0 px-3.5 pb-2.5 z-20 flex justify-between items-end">
          <p className="font-serif text-[14px] italic text-white leading-tight">
            {place.name}
          </p>
          <p className="font-sans text-[8.5px] text-white/50 text-right leading-snug">
            {place.district}
          </p>
        </div>
      </div>

      {/* 본문 */}
      <div className="bg-white px-3.5 py-3">
        <p className="font-serif text-[11px] italic text-[#6a6058] leading-[1.7] mb-2">
          "{place.story_quote}"
        </p>
        <div className="flex justify-between items-center">
          <div className="flex gap-1.5">
            {place.tags.map((tag) => (
              <span
                key={tag}
                className="font-sans text-[8px] tracking-wide text-ink-faint bg-page px-2 py-0.5 rounded-full"
              >
                {tag}
              </span>
            ))}
          </div>
          <span className="font-sans text-[9px] text-accent tracking-wide uppercase">
            보기 →
          </span>
        </div>
      </div>
    </div>
  )
}
```

- [ ] **Step 2: CardView 작성**

`components/theme/CardView.tsx`:
```typescript
import type { Place } from '@/lib/types'
import { PlaceCard } from './PlaceCard'

type Props = {
  places: Place[]
}

export function CardView({ places }: Props) {
  return (
    <div className="bg-[#f5f2ec] px-3.5 pt-3.5 pb-2">
      {places.map((place, i) => (
        <PlaceCard key={place.id} place={place} index={i} />
      ))}
    </div>
  )
}
```

- [ ] **Step 3: 커밋**

```bash
git add components/theme/PlaceCard.tsx components/theme/CardView.tsx
git commit -m "feat: add PlaceCard and CardView components"
```

---

## Task 12: Google Maps — ThemeMapView

**Files:**
- Create: `components/theme/ThemeMapView.tsx`
- Modify: `app/layout.tsx`

- [ ] **Step 1: layout.tsx에 Google Maps API 로드 추가**

`app/layout.tsx`의 `<html>` 태그 안에 추가:
```typescript
import { APIProvider } from '@vis.gl/react-google-maps'

// body 안의 div를 APIProvider로 감싸기:
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ko">
      <body>
        <APIProvider apiKey={process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY!}>
          <div className="max-w-sm mx-auto min-h-screen flex flex-col bg-page">
            <TopNav />
            <main className="flex-1 pb-16">
              {children}
            </main>
            <BottomTabs />
          </div>
        </APIProvider>
      </body>
    </html>
  )
}
```

- [ ] **Step 2: ThemeMapView 작성**

`components/theme/ThemeMapView.tsx`:
```typescript
'use client'

import { useState } from 'react'
import { Map, AdvancedMarker } from '@vis.gl/react-google-maps'
import type { Place, Theme } from '@/lib/types'

type Props = {
  theme: Theme
  places: Place[]
}

export function ThemeMapView({ theme, places }: Props) {
  const [selectedPlace, setSelectedPlace] = useState<Place | null>(null)

  const center = places.length > 0
    ? { lat: places[0].lat, lng: places[0].lng }
    : { lat: 35.0116, lng: 135.7681 } // 교토 기본

  return (
    <div className="relative" style={{ height: 'calc(100vh - 130px - 42px - 64px)' }}>
      {/* 상단 오버레이 바 */}
      <div className="absolute top-2.5 left-2.5 right-2.5 z-10 bg-surface/95 rounded-lg px-3 py-2 flex justify-between items-center shadow-md">
        <span className="font-serif text-[10px] italic text-ink">{theme.title}</span>
        <span className="font-sans text-[8.5px] text-accent">{theme.place_count}곳</span>
      </div>

      <Map
        defaultCenter={center}
        defaultZoom={14}
        mapId="citystorymap"
        disableDefaultUI
        gestureHandling="greedy"
        className="w-full h-full"
      >
        {places.map((place) => (
          <AdvancedMarker
            key={place.id}
            position={{ lat: place.lat, lng: place.lng }}
            onClick={() => setSelectedPlace(place)}
          >
            <div
              className={`rounded-full flex items-center justify-center shadow-md border-2 transition-all cursor-pointer ${
                selectedPlace?.id === place.id
                  ? 'w-10 h-10 text-lg bg-ink border-ink'
                  : 'w-8 h-8 text-base bg-white border-border'
              }`}
            >
              {place.emoji}
            </div>
          </AdvancedMarker>
        ))}
      </Map>

      {/* 선택된 장소 팝업 */}
      {selectedPlace && (
        <div className="absolute bottom-3 left-3 right-3 z-10 bg-white rounded-xl shadow-lg overflow-hidden flex">
          <div
            className="w-1.5 flex-shrink-0"
            style={{
              background: `linear-gradient(to bottom, ${theme.hero_gradient_from}, ${theme.hero_gradient_to})`,
            }}
          />
          <div className="flex items-center gap-2.5 px-3 py-2.5 flex-1">
            <span className="text-2xl flex-shrink-0">{selectedPlace.emoji}</span>
            <div className="flex-1 min-w-0">
              <p className="font-serif text-[11px] italic text-ink mb-0.5 truncate">
                {selectedPlace.name}
              </p>
              <p className="font-sans text-[9px] text-ink-faint leading-snug line-clamp-2">
                {selectedPlace.story_quote}
              </p>
            </div>
            <button
              onClick={() => setSelectedPlace(null)}
              className="font-sans text-[8.5px] text-accent tracking-wide uppercase flex-shrink-0 ml-1"
            >
              닫기
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
```

- [ ] **Step 3: 커밋**

```bash
git add components/theme/ThemeMapView.tsx app/layout.tsx
git commit -m "feat: add ThemeMapView with Google Maps pins and popup"
```

---

## Task 13: 테마 상세 페이지 조립

**Files:**
- Create: `app/theme/[themeId]/page.tsx`
- Create: `components/theme/ThemeDetailClient.tsx`

- [ ] **Step 1: ThemeDetailClient 작성 (뷰 탭 상태 관리)**

`components/theme/ThemeDetailClient.tsx`:
```typescript
'use client'

import { useState } from 'react'
import { ViewTabs } from './ViewTabs'
import { CardView } from './CardView'
import { ThemeMapView } from './ThemeMapView'
import type { Theme, Place } from '@/lib/types'

type Props = {
  theme: Theme
  places: Place[]
}

export function ThemeDetailClient({ theme, places }: Props) {
  const [view, setView] = useState<'card' | 'map'>('card')

  return (
    <>
      <ViewTabs view={view} onChange={setView} />
      {view === 'card'
        ? <CardView places={places} />
        : <ThemeMapView theme={theme} places={places} />
      }
    </>
  )
}
```

- [ ] **Step 2: 테마 상세 페이지 작성**

`app/theme/[themeId]/page.tsx`:
```typescript
import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { ThemeHero } from '@/components/theme/ThemeHero'
import { ThemeDetailClient } from '@/components/theme/ThemeDetailClient'
import type { Theme, Place } from '@/lib/types'

type Props = {
  params: { themeId: string }
}

export default async function ThemeDetailPage({ params }: Props) {
  const supabase = createClient()

  const { data: theme } = await supabase
    .from('themes_with_count')
    .select('*')
    .eq('id', params.themeId)
    .single()

  if (!theme) notFound()

  const { data: places } = await supabase
    .from('places')
    .select('*')
    .eq('theme_id', params.themeId)
    .order('order', { ascending: true })

  return (
    <>
      <ThemeHero theme={theme as Theme} />
      <ThemeDetailClient theme={theme as Theme} places={(places as Place[]) ?? []} />
    </>
  )
}
```

- [ ] **Step 3: 개발 서버에서 확인**

```bash
npm run dev
```

Expected: 홈에서 스토리 클릭 → 테마 상세 이동. 카드뷰/지도뷰 탭 전환 작동. 지도에 핀 표시됨. 핀 클릭 시 팝업 등장.

- [ ] **Step 4: 커밋**

```bash
git add app/theme/ components/theme/ThemeDetailClient.tsx
git commit -m "feat: theme detail page with card/map view toggle"
```

---

## Task 14: 글로벌 지도 탭

**Files:**
- Create: `components/map/GlobalMapView.tsx`
- Create: `app/map/page.tsx`

- [ ] **Step 1: GlobalMapView 작성**

`components/map/GlobalMapView.tsx`:
```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Map, AdvancedMarker } from '@vis.gl/react-google-maps'
import type { Theme, Place } from '@/lib/types'

type PlaceWithTheme = Place & { theme: Theme }

type Props = {
  places: PlaceWithTheme[]
}

export function GlobalMapView({ places }: Props) {
  const router = useRouter()
  const [selected, setSelected] = useState<PlaceWithTheme | null>(null)

  const KYOTO_CENTER = { lat: 35.0116, lng: 135.7681 }

  return (
    <div className="relative" style={{ height: 'calc(100vh - 48px - 64px)' }}>
      <Map
        defaultCenter={KYOTO_CENTER}
        defaultZoom={13}
        mapId="citystorymap-global"
        disableDefaultUI
        gestureHandling="greedy"
        className="w-full h-full"
      >
        {places.map((place) => (
          <AdvancedMarker
            key={place.id}
            position={{ lat: place.lat, lng: place.lng }}
            onClick={() => setSelected(place)}
          >
            <div
              className={`rounded-full flex items-center justify-center shadow-md border-2 cursor-pointer transition-all ${
                selected?.id === place.id
                  ? 'w-10 h-10 text-lg bg-ink border-ink'
                  : 'w-7 h-7 text-sm bg-white border-border'
              }`}
            >
              {place.emoji}
            </div>
          </AdvancedMarker>
        ))}
      </Map>

      {selected && (
        <div className="absolute bottom-3 left-3 right-3 z-10 bg-white rounded-xl shadow-lg overflow-hidden flex">
          <div
            className="w-1.5 flex-shrink-0"
            style={{
              background: `linear-gradient(to bottom, ${selected.theme.hero_gradient_from}, ${selected.theme.hero_gradient_to})`,
            }}
          />
          <div className="flex items-center gap-2.5 px-3 py-2.5 flex-1">
            <span className="text-2xl flex-shrink-0">{selected.emoji}</span>
            <div className="flex-1 min-w-0">
              <p className="font-sans text-[8px] tracking-wide uppercase text-ink-muted mb-0.5 truncate">
                {selected.theme.title}
              </p>
              <p className="font-serif text-[11px] italic text-ink truncate">
                {selected.name}
              </p>
            </div>
            <button
              onClick={() => router.push(`/theme/${selected.theme.id}`)}
              className="font-sans text-[8.5px] text-accent tracking-wide uppercase flex-shrink-0"
            >
              보기 →
            </button>
          </div>
        </div>
      )}
    </div>
  )
}
```

- [ ] **Step 2: 글로벌 지도 페이지 작성**

`app/map/page.tsx`:
```typescript
import { createClient } from '@/lib/supabase/server'
import { GlobalMapView } from '@/components/map/GlobalMapView'
import type { Theme, Place } from '@/lib/types'

export default async function MapPage() {
  const supabase = createClient()

  const { data: places } = await supabase
    .from('places')
    .select(`
      *,
      theme:themes_with_count(*)
    `)

  return <GlobalMapView places={(places ?? []) as any} />
}
```

- [ ] **Step 3: 개발 서버에서 전체 플로우 확인**

```bash
npm run dev
```

Expected:
- 홈 캐러셀 자동 슬라이드 ✓
- 스토리 클릭 → 테마 상세 ✓
- 카드뷰 / 지도뷰 탭 전환 ✓
- 지도 핀 클릭 팝업 ✓
- 하단 탭 → 지도 탭 → 교토 전체 핀 ✓

- [ ] **Step 4: 커밋**

```bash
git add components/map/ app/map/
git commit -m "feat: global map page with all place pins"
```

---

## Task 15: 빌드 검증 + Vercel 배포

**Files:**
- Create: `vercel.json` (필요 시)

- [ ] **Step 1: 프로덕션 빌드 확인**

```bash
npm run build
```

Expected: 에러 없이 빌드 완료. TypeScript 에러 0개.

- [ ] **Step 2: Vercel 배포**

```bash
npx vercel
```

또는 GitHub 연결 후 자동 배포:
1. GitHub에 리포지토리 push
2. vercel.com → Import Project → 리포 선택
3. Environment Variables에 `.env.local` 내용 추가:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`

- [ ] **Step 3: 배포된 URL에서 전체 기능 확인**

Expected: 로컬과 동일하게 모든 화면 작동

- [ ] **Step 4: 최종 커밋**

```bash
git add .
git commit -m "chore: production build verified, deploy to Vercel"
```

---

## 스펙 커버리지 체크

| PRD 요구사항 | 구현 태스크 |
|-------------|------------|
| 홈: 캐러셀 (3.5초 자동 슬라이드, 닷 인디케이터) | Task 7 |
| 홈: 전체 스토리 리스트 | Task 8 |
| 홈: 스토리/지도 하단 탭 | Task 6 |
| 테마 상세: 히어로 헤더 (어두운 그라디언트, 뒤로가기) | Task 10 |
| 테마 상세: 카드뷰/지도뷰 탭 전환 | Task 10, 13 |
| 테마 상세: 장소 카드 (이미지 영역 + 인용문 + 태그) | Task 11 |
| 테마 상세: 지도뷰 (핀 + 팝업) | Task 12 |
| 글로벌 지도 탭 | Task 14 |
| Supabase DB + 교토 시드 데이터 | Task 3 |
| 디자인 시스템 (earth tone, Georgia serif) | Task 5 |
