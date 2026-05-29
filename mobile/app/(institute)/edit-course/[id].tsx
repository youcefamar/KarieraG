import { useLocalSearchParams } from "expo-router";

import { Screen } from "@/components/Screen";

export default function EditCourse() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <Screen title={`Edit Course #${id}`} />;
}
