import { useLocalSearchParams } from "expo-router";

import { Screen } from "@/components/Screen";

export default function CourseDetails() {
  const { id } = useLocalSearchParams<{ id: string }>();
  return <Screen title={`Course Details #${id}`} />;
}
