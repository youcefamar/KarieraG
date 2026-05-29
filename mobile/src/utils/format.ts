export function formatPriceDZD(value: string | null): string {
  if (!value) return "Free";
  return `${Number(value).toLocaleString("fr-DZ")} DZD`;
}
