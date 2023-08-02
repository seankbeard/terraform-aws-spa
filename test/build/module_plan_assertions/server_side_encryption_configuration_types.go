package buildstagetests

type applyServerSideEncryptionByDefaultConfigurationBlock struct {
	KmsMasterKeyId string `json:"kms_master_key_id"`
	SseAlgorithm   string `json:"sse_algorithm"`
}

type rule struct {
	ApplyServerSideEncryptionByDefault []applyServerSideEncryptionByDefaultConfigurationBlock `json:"apply_server_side_encryption_by_default"`
	BucketKeyEnabled                   interface{}                                            `json:"bucket_key_enabled"`
}
type encryptionConfiguration struct {
	Bucket              string      `json:"bucket"`
	ExpectedBucketOwner interface{} `json:"expected_bucket_owner"`
	Rule                []rule      `json:"rule"`
}
