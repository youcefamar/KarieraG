import { create } from "zustand";

import { clearTokens } from "@/lib/secure-storage";
import type { User } from "@/types";

interface AuthState {
  user: User | null;
  setUser: (user: User | null) => void;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  logout: async () => {
    await clearTokens();
    set({ user: null });
  },
}));
