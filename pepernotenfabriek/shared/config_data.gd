extends Resource
class_name ConfigData

@export_group("Map")
@export var camera_edge_margin := Vector2(0.0, 64.0)

@export_subgroup("Generator")
@export var grid_size := Vector2(10,8)
@export var grid_size_factor := 1.0
@export var num_belts := 4

@export var basket_quantity_factor := 1.0
@export var min_num_baskets := 14
@export var max_num_baskets := 20
@export var max_dist_basket_to_machine := 4

@export_subgroup("Baskets")
@export var basket_area_size_factor := 0.7

@export_subgroup("Machines")
@export var machine_max_held_time := 2000.0 # ms
@export var enable_aim_assistance := true
@export var aim_assistance_diff_threshold := 0.25*PI
@export var max_aim_assistance_correction := 0.075*PI # must be lower than threshold

@export var machine_randomize_dir_at_start := true
@export var machine_rotate_speed := 0.5
@export var machine_rotate_speed_held := 7.5

@export var enable_max_machines_per_player := false
@export var max_machines_per_player := 2

@export_subgroup("Conveyor Belts")
@export var belt_push_force := 750.0
@export var belt_max_push_change_per_frame := 100.0
@export var belt_extra_margin_factor := 0.25 # ~belt_thickness

@export_group("Gifts")
@export var gift_standstill_delay_before_removal := 10.0 # s

@export_group("Bullets")
@export var bullet_min_fire_speed := 125.0
@export var bullet_max_fire_speed := 2000.0
@export var bullet_speed_factor := 1.0

@export_group("Objective")
@export_subgroup("Target")
@export var gifts_target_min : int = 10
@export var gifts_target_max : int = 40
@export var gifts_target_factor := 1.0

@export_subgroup("Score")
@export var score_min := 1.0 # per gift delivered
@export var score_max := 10.0

@export var mult_min := 1.0
@export var mult_max := 5.0

@export_subgroup("Combo Streaks")
@export var break_player_streak_for_failed_gifts := true
@export var break_global_streak_for_failed_gifts := true
