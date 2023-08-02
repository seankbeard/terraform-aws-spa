package buildstagetests

type viewCertificate struct {
	AcmCertificateArn            interface{} `json:"acm_certificate_arn"`
	CloudfrontDefaultCertificate bool        `json:"cloudfront_default_certificate"`
	IamCertificateId             interface{} `json:"iam_certificate_id"`
	MinimumProtocolVersion       string      `json:"minimum_protocol_version"`
	SslSupportMethod             interface{} `json:"ssl_support_method"`
}

type defaultCustomBehavior struct {
	AllowedMethods         []string    `json:"allowed_methods"`
	CachePolicyId          interface{} `json:"cache_policy_id"`
	CachedMethods          []string    `json:"cached_methods"`
	Compress               bool        `json:"compress"`
	DefaultTtl             int         `json:"default_ttl"`
	FieldLevelEncryptionId interface{} `json:"field_level_encryption_id"`
	ForwardedValues        []struct {
		Cookies []struct {
			Forward string `json:"forward"`
		} `json:"cookies"`
		QueryString bool `json:"query_string"`
	} `json:"forwarded_values"`
	FunctionAssociation       []interface{} `json:"function_association"`
	LambdaFunctionAssociation []interface{} `json:"lambda_function_association"`
	MaxTtl                    int           `json:"max_ttl"`
	MinTtl                    int           `json:"min_ttl"`
	OriginRequestPolicyId     interface{}   `json:"origin_request_policy_id"`
	RealtimeLogConfigArn      interface{}   `json:"realtime_log_config_arn"`
	ResponseHeadersPolicyId   interface{}   `json:"response_headers_policy_id"`
	SmoothStreaming           interface{}   `json:"smooth_streaming"`
	TargetOriginId            string        `json:"target_origin_id"`
	ViewerProtocolPolicy      string        `json:"viewer_protocol_policy"`
}

type customErrorResponse struct {
	ErrorCachingMinTtl interface{} `json:"error_caching_min_ttl"`
	ErrorCode          int         `json:"error_code"`
	ResponseCode       int         `json:"response_code"`
	ResponsePagePath   string      `json:"response_page_path"`
}
type origin struct {
	ConnectionAttempts    int           `json:"connection_attempts"`
	ConnectionTimeout     int           `json:"connection_timeout"`
	CustomHeader          []interface{} `json:"custom_header"`
	CustomOriginConfig    []interface{} `json:"custom_origin_config"`
	OriginAccessControlId string        `json:"origin_access_control_id"`
	OriginId              string        `json:"origin_id"`
	OriginPath            string        `json:"origin_path"`
	OriginShield          []interface{} `json:"origin_shield"`
	S3OriginConfig        []struct{}    `json:"s3_origin_config"`
}
type geoRestriction struct {
	RestrictionType string `json:"restriction_type"`
}

type restrictions struct {
	GeoRestriction []geoRestriction `json:"geo_restriction"`
}

type cloudfrontDistribution struct {
	Aliases              interface{}             `json:"aliases"`
	Comment              interface{}             `json:"comment"`
	CustomErrorResponse  []customErrorResponse   `json:"custom_error_response"`
	DefaultCacheBehavior []defaultCustomBehavior `json:"default_cache_behavior"`
	DefaultRootObject    string                  `json:"default_root_object"`
	Enabled              bool                    `json:"enabled"`
	HttpVersion          string                  `json:"http_version"`
	IsIpv6Enabled        bool                    `json:"is_ipv6_enabled"`
	LoggingConfig        []struct{}              `json:"logging_config"`
	OrderedCacheBehavior []interface{}           `json:"ordered_cache_behavior"`
	Origin               []origin                `json:"origin"`
	OriginGroup          []interface{}           `json:"origin_group"`
	PriceClass           string                  `json:"price_class"`
	Restrictions         []restrictions          `json:"restrictions"`
	RetainOnDelete       bool                    `json:"retain_on_delete"`
	Tags                 interface{}             `json:"tags"`
	ViewerCertificate    []viewCertificate       `json:"viewer_certificate"`
	WaitForDeployment    bool                    `json:"wait_for_deployment"`
	WebAclId             interface{}             `json:"web_acl_id"`
}
