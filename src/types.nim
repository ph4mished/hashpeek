type
  HashCandidate* = object
    hash*: string
    candidates*: seq[HashType]
    confidence*: float
    context*: string
    
  HashType* = object
    name*: string
    confidence*: float
    characteristics*: string
    hashcatMode*: int
    johnFormat*: string
    
  ScanResult* = object
    totalHashes*: int
    uniqueHashes*: int
    groups*: seq[HashGroup]
    processingTime*: float
    memoryUsed*: int
    
  HashGroup* = object
    name*: string
    count*: int
    percentage*: float
    primaryType*: HashType
    alternativeTypes*: seq[HashType]
    sampleHashes*: seq[string]
    securityImpact*: SecurityLevel
    
  SecurityLevel* = enum
    slCritical = "CRITICAL"
    slWarning = "WARNING" 
    slSecure = "SECURE"
    slInfo = "INFO"