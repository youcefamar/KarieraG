// Central list of API paths (relative to EXPO_PUBLIC_API_URL).
export const endpoints = {
  auth: {
    login: "/auth/login/",
    refresh: "/auth/refresh/",
    register: "/auth/register/",
    me: "/auth/me/",
  },
  courses: {
    list: "/courses/",
    detail: (id: number | string) => `/courses/${id}/`,
    favorite: (id: number | string) => `/courses/${id}/favorite/`,
    similar: (id: number | string) => `/courses/${id}/similar/`,
  },
  ai: {
    advisor: "/ai/course-advisor/",
    semanticSearch: "/ai/semantic-search/",
    match: "/ai/course-match/",
    roadmap: "/ai/roadmap/",
  },
} as const;
