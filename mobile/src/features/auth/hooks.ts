import { useMutation } from "@tanstack/react-query";

import { api } from "@/api/client";
import { endpoints } from "@/api/endpoints";
import { setTokens } from "@/lib/secure-storage";
import type { LoginInput } from "./schema";

// TODO: fetch /auth/me after login and populate useAuthStore.
export function useLogin() {
  return useMutation({
    mutationFn: async (input: LoginInput) => {
      const { data } = await api.post(endpoints.auth.login, input);
      await setTokens(data.access, data.refresh);
      return data;
    },
  });
}
