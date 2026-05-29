import { SafeAreaView } from "react-native-safe-area-context";
import { Text, View } from "react-native";

/** Placeholder screen scaffold used by all skeleton routes. */
export function Screen({ title }: { title: string }) {
  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="flex-1 items-center justify-center p-6">
        <Text className="text-xl font-bold text-primary">{title}</Text>
        <Text className="mt-2 text-gray-500">Placeholder — to be implemented.</Text>
      </View>
    </SafeAreaView>
  );
}
