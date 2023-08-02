package buildstagetests

type publicAccessBlock struct {
	BlockPublicAcls       bool   `json:"block_public_acls"`
	BlockPublicPolicy     bool   `json:"block_public_policy"`
	Bucket                string `json:"bucket"`
	IgnorePublicAcls      bool   `json:"ignore_public_acls"`
	RestrictPublicBuckets bool   `json:"restrict_public_buckets"`
}
