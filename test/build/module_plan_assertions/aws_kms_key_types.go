package buildstagetests

type kmsKey struct {
	BypassPolicyLockoutSafetyCheck bool        `json:"bypass_policy_lockout_safety_check"`
	CustomKeyStoreId               interface{} `json:"custom_key_store_id"`
	CustomerMasterKeySpec          string      `json:"customer_master_key_spec"`
	DeletionWindowInDays           int         `json:"deletion_window_in_days"`
	Description                    string      `json:"description"`
	EnableKeyRotation              bool        `json:"enable_key_rotation"`
	IsEnabled                      bool        `json:"is_enabled"`
	KeyUsage                       string      `json:"key_usage"`
	Tags                           interface{} `json:"tags"`
}
