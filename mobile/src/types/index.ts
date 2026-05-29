export type Role = "student" | "trainer" | "institute_owner" | "admin";

export interface User {
  id: number;
  email: string;
  username: string;
  role: Role;
  phone?: string;
}

export interface Course {
  id: number;
  title: string;
  about: string;
  institute: number;
  category: number | null;
  price_dzd: string | null;
  duration: string;
  location: string;
  mode: "onsite" | "online";
  status: "open" | "closed";
  image_url: string;
  is_featured: boolean;
}
