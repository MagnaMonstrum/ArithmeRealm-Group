extends Node
class_name ProblemGenerator

const DEFAULT_RANGE := Vector2i(0, 20)

const DIFFICULTY_CONFIG: Dictionary = {
	1: {
		"name": "Groep 6 - Basis rekenen",
		"operators": ["add", "sub", "mul"],
		"range": Vector2i(10, 100),
		"chest_range": Vector2i(20, 200),
		"mul_max": 12,
		"div_max": 100
	},
	2: {
		"name": "Groep 7 - Verdieping",
		"operators": ["add", "sub", "mul", "div"],
		"range": Vector2i(50, 500),
		"chest_range": Vector2i(100, 1000),
		"mul_max": 50,
		"div_max": 500
	},
	3: {
		"name": "Groep 8 - Uitdaging",
		"operators": ["add", "sub", "mul", "div"],
		"range": Vector2i(100, 1000),
		"chest_range": Vector2i(500, 5000),
		"mul_max": 99,
		"div_max": 1000
	}
}

static var rng: RandomNumberGenerator = RandomNumberGenerator.new()
static var _rng_ready: bool = false

static func _ensure_rng() -> void:
	if not _rng_ready:
		rng.randomize()
		_rng_ready = true

static func get_level_config(level: int) -> Dictionary:
	var clamped: int = clamp(level, 1, 3)
	return DIFFICULTY_CONFIG.get(clamped, DIFFICULTY_CONFIG[1])

static func make_problem(level: int, target_answer: int = -1, context: String = "standard") -> Dictionary:
	_ensure_rng()
	var cfg: Dictionary = get_level_config(level)
	var range_key := context == "chest" and "chest_range" or "range"
	var range_vals: Vector2i = cfg.get(range_key, cfg.get("range", DEFAULT_RANGE))
	var min_val: int = range_vals.x
	var max_val: int = range_vals.y
	var op_list: Array = cfg.get("operators", ["add"])
	var op: String = "add"
	if op_list.size() > 0:
		op = String(op_list[rng.randi_range(0, op_list.size() - 1)])

	var op_symbol: String = _get_op_symbol(op)
	var a: int = 0
	var b: int = 0
	var answer: int = 0

	if target_answer >= 0:
		var generated: Dictionary = _build_problem_for_target(target_answer, op, min_val, max_val)
		if generated.has("a"):
			a = int(generated["a"])
			b = int(generated["b"])
			answer = target_answer
		else:
			op = "add"
			op_symbol = _get_op_symbol(op)
			var a_min: int = max(min_val, 0)
			var a_max: int = min(target_answer, max_val)
			a = rng.randi_range(a_min, a_max)
			b = target_answer - a
			answer = target_answer
	else:
		match op:
			"sub":
				a = rng.randi_range(min_val, max_val)
				b = rng.randi_range(min_val, min(a, max_val))
				answer = a - b
			"mul":
				var mul_limit: int = cfg.get("mul_max", 12)
				a = rng.randi_range(2, min(mul_limit, max_val))
				b = rng.randi_range(2, min(mul_limit, max_val))
				answer = a * b
			"div":
				var div_limit: int = cfg.get("div_max", 100)
				b = rng.randi_range(2, min(12, max_val))
				var quotient: int = rng.randi_range(2, min(div_limit / b, max_val / b))
				a = b * quotient
				answer = quotient
			_:
				a = rng.randi_range(min_val, max_val)
				b = rng.randi_range(min_val, max_val)
				answer = a + b

	return {
		"a": a,
		"b": b,
		"operator": op,
		"operator_symbol": op_symbol,
		"answer": answer,
		"label": "%d %s %d" % [a, op_symbol, b]
	}

static func _get_op_symbol(op: String) -> String:
	match op:
		"sub":
			return "-"
		"mul":
			return "x"
		"div":
			return ":"
		_:
			return "+"

static func _build_problem_for_target(target_answer: int, op: String, min_val: int, max_val: int) -> Dictionary:
	match op:
		"sub":
			var b: int = rng.randi_range(min_val, min(target_answer, max_val))
			var a: int = target_answer + b
			if a < min_val:
				return {}
			return {"a": a, "b": b}
		"mul":
			var factors: Array[int] = []
			for i in range(2, min(max_val, target_answer) + 1):
				if target_answer % i == 0:
					var other: int = target_answer / i
					if other >= 2 and other <= max_val:
						factors.append(i)
			if factors.is_empty():
				return {}
			var a_idx: int = rng.randi_range(0, factors.size() - 1)
			var a: int = factors[a_idx]
			var b: int = target_answer / a
			return {"a": a, "b": b}
		"div":
			var divisors: Array[int] = []
			for d in range(2, min(12, max_val) + 1):
				var product: int = target_answer * d
				if product <= max_val * 2:
					divisors.append(d)
			if divisors.is_empty():
				return {}
			var b: int = divisors[rng.randi_range(0, divisors.size() - 1)]
			var a: int = target_answer * b
			return {"a": a, "b": b}
		_:
			var a_min: int = max(min_val, 0)
			var a_max: int = min(target_answer, max_val)
			if a_min > a_max:
				return {}
			var a: int = rng.randi_range(a_min, a_max)
			var b: int = target_answer - a
			return {"a": a, "b": b}
