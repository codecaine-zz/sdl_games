module main

struct MotionState {
pub mut:
	x           f64
	y           f64
	vx          f64
	vy          f64
	is_grounded bool
}

const gravity = 420.0
const air_drag = 0.985
const max_fall_speed = 380.0

fn apply_flap(mut m MotionState, power f64) {
	m.vy -= power
	if m.vy < -340.0 {
		m.vy = -340.0
	}
	m.is_grounded = false
}

fn update_motion(mut m MotionState, dt f64, world_w f64) {
	if !m.is_grounded {
		m.vy += gravity * dt
		if m.vy > max_fall_speed {
			m.vy = max_fall_speed
		}
	}

	m.vx *= air_drag
	m.x += m.vx * dt
	m.y += m.vy * dt

	// Screen edge wraparound
	if m.x < -20.0 {
		m.x += world_w + 40.0
	} else if m.x > world_w + 20.0 {
		m.x -= world_w + 40.0
	}
}

struct Platform {
pub mut:
	x f64
	y f64
	w f64
	h f64
}

fn check_platform_landing(mut m MotionState, char_w f64, char_h f64, platform Platform) bool {
	char_left := m.x - (char_w / 2.0)
	char_right := m.x + (char_w / 2.0)
	char_bottom := m.y + (char_h / 2.0)
	prev_bottom := (m.y - m.vy * 0.016) + (char_h / 2.0)

	if char_right >= platform.x && char_left <= platform.x + platform.w {
		if prev_bottom <= platform.y + 4.0 && char_bottom >= platform.y {
			m.y = platform.y - (char_h / 2.0)
			m.vy = 0
			m.is_grounded = true
			return true
		}
	}
	return false
}
