import { useQuery } from "@tanstack/react-query";

import { api } from "@/api/client";
import { endpoints } from "@/api/endpoints";
import type { Course } from "@/types";

export function useCourses() {
  return useQuery({
    queryKey: ["courses"],
    queryFn: async () => {
      const { data } = await api.get<Course[]>(endpoints.courses.list);
      return data;
    },
  });
}
