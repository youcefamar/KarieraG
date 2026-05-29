import axios from "axios";

import { getAccessToken } from "@/lib/secure-storage";

export const api = axios.create({
  baseURL: process.env.EXPO_PUBLIC_API_URL,
  timeout: 15000,
});

// Attach JWT access token to every request.
api.interceptors.request.use(async (config) => {
  const token = await getAccessToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

// TODO: response interceptor to refresh token on 401 (see features/auth).
