/// Backend Decimal/BigInt fields (e.g. Prisma `Decimal`) serialize as JSON
/// strings, not numbers — these helpers accept either.
int parseInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? (num.tryParse(value)?.toInt() ?? fallback);
  return fallback;
}

num parseNum(dynamic value, [num fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? fallback;
  return fallback;
}
