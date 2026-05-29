# Kariera Mobile

React Native + Expo + TypeScript app. **Skeleton only** — screens are placeholders.

## Stack
- Expo + Expo Router (file-based routing, typed routes)
- TanStack Query (server state) + Axios (HTTP)
- Zustand (client state) + secure token storage (expo-secure-store)
- Zod + React Hook Form (validation)
- NativeWind (Tailwind styling)

## Structure
```
mobile/
├── app/              # Expo Router routes (file-based)
│   ├── (auth)/       # onboarding, login, signup
│   ├── (student)/    # tabs: home, search, favorites, history, profile + ai/roadmap/notifications/settings
│   └── (institute)/  # dashboard, add/edit course
└── src/
    ├── api/          # axios client + endpoints
    ├── components/   # shared UI
    ├── features/     # auth, courses, enrollments, recommendations, profile, notifications, ai-advisor
    ├── hooks/        # react-query hooks
    ├── lib/          # query client, secure storage
    ├── stores/       # zustand stores
    ├── types/        # shared TS types
    └── utils/        # helpers
```

## Run
```bash
cp .env.example .env      # set EXPO_PUBLIC_API_URL
npm install
npx expo start
```

> `EXPO_PUBLIC_API_URL` must point at the backend `/api/v1`. On a physical
> device use your machine LAN IP instead of `localhost`.
