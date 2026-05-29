import { Redirect } from "expo-router";

// TODO: branch on auth state (useAuthStore) once auth is wired.
export default function Index() {
  return <Redirect href="/(auth)/onboarding" />;
}
