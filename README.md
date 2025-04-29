# 📂 ChoonAssistant Cloud Repository

**이 레포지토리는 춘비서 프로젝트의 Cloud Infrastructure(AWS, GCP)를 Terraform을 통해 관리하는 공간입니다. IaC(Infra as Code) 방식을 따릅니다.**

> 문서 내용은 프로젝트 진행 상황에 따라 변경될 수 있습니다.

---

# 📁 Repository Structure

```hcl
/ (root)
├── .github/          # GitHub Actions 워크플로우, ISSUE 템플릿 등 관리 예정
├── README.md         # 레포지토리 소개 및 협업 가이드
├── scripts/          # 배포 자동화 스크립트 모음
│   ├── v1/           # 초기 버전 (MVP 배포용), 구조 확정
│   ├── v2/           # 구조 확정 전
│   ├── v3/           # 구조 확정 전
│   ├── v4/           # 구조 확정 전
├── terraform/
│   ├── v1/           # 초기 버전 (MVP 배포용), 구조 확정
│   │   ├── modules/
│   │   │   ├── network/   # VPC, Subnet, Route Table 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   ├── compute/   # EC2, AutoScaling Group 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   ├── database/  # RDS, ElastiCache 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   ├── security/  # Security Group, IAM 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   ├── monitoring/  # CloudWatch, CloudWatch Alarm 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   ├── deployment/ # CodeDeploy, CodePipeline 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   ├── notification/ # SNS, EventBridge 등
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   ├── envs/
│   │   │   ├── mvp/
│   │   │   │   ├── main.tf
│   │   │   │   ├── variables.tf
│   │   │   │   ├── outputs.tf
│   │   │   │   └── terraform.tfvars
│   │   ├── backend/
│   │   ├── provider.tf
│   │   ├── versions.tf
│   │   └── README.md # 버전별 가이드 (필요 시)
│   ├── v2/           # 구조 개선 또는 확장 예정
│   ├── v3/           # 신규 기능 추가 및 개선 예정
│   ├── v4/           # 대규모 리팩토링 및 확장 예정
```

## 🔄 Versioning Policy

- 버전(v1, v2, v3, v4)은 **디렉토리로 명시적으로 구분**
- 버전별 디렉토리(`v2/`, `v3/`, `v4/`)는 향후 구체화되면서 세부 구조가 변경될 수 있음
- 모든 버전은 독립적으로 관리하며, 필요한 경우 서로 다른 인프라 구성을 허용

---

# 📚 Terraform Collaboration Guide

본 내용은 다음을 참고했습니다. -> https://www.terraform-best-practices.com/ko

## 🔌 명명 규칙

1. 리소스 이름, 데이터 소스 이름, 변수 이름, 출력 등 모든 곳에서 `-`(dash) 대신 `_`(밑줄)을 사용
2. 소문자와 숫자를 사용

#### 리소스 및 데이터 소스 인수

1. 리소스 이름에 리소스 유형을 반복하지 않음
	- ✅ `resource "aws_route_table" "public" {}`
	- ❌ `resource "aws_route_table" "public_route_table" {}`
2. 모듈에 여러 개의 리소스를 생성하는 경우, 더 자세한 이름을 짓는다.
	- 예: `aws_nat_gateway` 리소스 한 개와 `aws_route_table` 유형의 리소스가 여러 개 있는 경우 
	- `aws_nat_gateway`는 `this`로, `aws_route_table`은 `private`, `public`, `database` 등
3. 이름에는 항상 단수 명사를 사용
4. 예외적으로 인수 값 내부와 같이 사람에게 노출되는 값에는 `-`(dash)를 사용
	> `.tfvars` 내부의 값 같은 것들
5. 리소스 또는 데이터 소스 블록 내부에 인수 `count` / `for_each`를 맨 위의 첫 번째 인수로 포함하고 그 뒤는 줄바꿈으로 구분
6. `tags`, `depends_on` 및 `lifecycle`은 마지막 인수로 선언. 이들 모두는 하나의 빈 줄로 구분

##### `resource` 코드 예시

```hcl
resource "aws_route_table" "public" {
  count = 2

  vpc_id = "vpc-12345678"
  # ... remaining arguments omitted
}

resource "aws_route_table" "private" {
  for_each = toset(["one", "two"])

  vpc_id = "vpc-12345678"
  # ... remaining arguments omitted
}
```
---
```hcl
resource "aws_nat_gateway" "this" {
  count = 2

  allocation_id = "..."
  subnet_id     = "..."

  tags = {
    Name = "..."
  }

  depends_on = [aws_internet_gateway.this]

  lifecycle {
    create_before_destroy = true
  }
}   
```

#### 변수(variables)

1. 변수를 만들 때, 작업 중인 리소스에 대한 "Argument Reference" 섹션에 정의된 대로 변수에 대한 `name`, `description`, 및 `default` 값을 사용
	- 참고: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
2. 유형이 `list(...)` 또는 `map(...)`인 경우 변수 이름에 복수형을 사용
3. 분명하다고 생각되더라도 항상 모든 변수에 대해 `description`을 포함
4. 각 키에 엄격한 제약을 적용하 필요가 없는 한 `object()`와 같은 특정 유형보다는 간단한 유형(`number`, `string`, `list(...)`, `map(...)`, `any`)을 사용

#### 출력(outputs)

기본적으로 모듈의 범위 밖에서도 출력을 일관되고 이해하기 쉽게 만들어야 함(반환되는 값의 유형과 속성 명확하게)
1. 출력 이름의 적합한 구조는 `{name}_{type}_{attribute}`이다
	- `{name}`은 리소스 또는 데이터 소스 이름
		- `aws_subnet`의 `{name}`은 `subnet` / `aws_vpc`의 `{name}`은 `vpc`
	- `{type}`은 리소스 소스의 유형
	- `{attribute}`는 출력이 반환하는 속성 (optional)
2. 반환된 값이 리스트인 경우 복수형 이름을 가져야 함
3. 분명하다고 생각되더라도 항상 모든 변수에 대한 `description`을 포함

##### `output` 코드 예시

```hcl
output "security_group_id" {
  description = "The ID of the security group"
  value       = try(aws_security_group.this[0].id, aws_security_group.name_prefix[0].id, "")
}
```
---
```hcl
output "rds_cluster_instance_endpoints" {
  description = "A list of all cluster instance endpoints"
  value       = aws_rds_cluster_instance.this.*.endpoint
}
```

## 🔌 파일 규칙

| 파일명 | 역할 |
|:-------|:-----|
| main.tf | 리소스 모듈 호출 및 실제 리소스 생성 |
| variables.tf | 필요한 변수 정의 |
| outputs.tf | 리소스 출력 값 정의 |
| terraform.tfvars | 변수 실제 값 입력 |
| provider.tf | AWS, GCP Provider 설정 |
| versions.tf | Terraform 및 Provider 버전 고정 |

#### `main.tf`
> 리소스 생성의 중심이 되는 파일

- 가능한 모든 리소스는 `modules/` 하위 모듈로 분리해서 호출
- 하드코딩 최소화, 변수(`var`) 사용 필수

##### 예시

```hcl
module "vpc" {
  source = "../modules/network"

  vpc_name = var.vpc_name
  cidr_block = var.cidr_block
}
```
-> `envs/` 내부의 `main.tf` (`modules/` 내부의 vpc 모듈을 호출)

#### `variables.tf`
> 외부에서 입력받을 변수들의 타입, 설명, 기본값(optional)을 선언하는 파일

- 변수 그룹핑 규칙: 리소스별(network, compute 등) 또는 기능별로 묶어서 선언
  
#### `outputs.tf`
> 리소스 생성 결과를 외부로 출력하는 파일 (예: VPC ID, Subnet ID 등)

- 외부에서 참조할 필요가 있는 리소스만 output
- 불필요한 출력은 지양
- `outputs.tf` 파일은 필요할 때만 작성 -> 불필요하다면 파일만 만들어두고 비워두기

#### `terraform.tfvars`
> `variables.tf`에서 정의한 변수들에 실제 값을 채워넣는 파일. 환경마다 값이 다를 수 있음

- 환경(dev, prod 등)마다 별도로 관리
- 민감 정보는 입력하지 않음
- Key 정렬, 주석으로 그룹핑해 가독성 유지

##### 예시
```hcl
vpc_name  = "my-dev-vpc"
cidr_block = "10.1.0.0/16"
```

#### `providers.tf`
> 사용할 클라우드 Provider를 선언하는 파일

- Provider 이름, region, 기본 설정 명시
- 환경 간에 Provider 차이가 있으면 별도 파일로 분리

##### 예시

```
provider "aws" {
	region = "ap-northeast-2"
	profile = "personal"
	# 하드 코딩하면 안됨
	access_key = "XXXXXXXX"
	secret_key = "XXXXXXXX"
}
provider "google" {
	region = "asia-northeast1"
}
```

#### `versions.tf`
> `versions.tf` 파일로 Terraform 및 Provider 버전을 고정

- 모든 팀원은 같은 Terraform CLI 버전 및 Provider 버전을 사용

##### 예시
```
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}
```

## 🛠️ Code Convention
- Terraform 공식 포맷터인 `terraform fmt`를 사용하여 코드 스타일을 통일합니다.
- 모든 `.tf` 파일은 `terraform fmt` 적용 후 커밋합니다.

### Naming Rule
- 들여쓰기는 **2 spaces** (Tab 금지)
- 네이밍은 모두 **snake_case** 사용
- 모든 리소스에는 **tags** 필수 작성

### Tag Rule
```hcl
tags = {
  Project     = "choon-assistant"
  Environment = "mvp"        # v1은 mvp, 이후 버전은 dev, prod 등으로 구분
  Module      = "network"    # 모듈명 (network, compute, database, security, monitoring 등)
  Version     = "v1"         # Terraform 코드 버전
  Assignee    = "nilla"      # nilla, river, denver
}
```

## 📖 Collaboration Rules
- 변경사항 발생 시 Pull Request 작성 및 리뷰 필수
- main 브랜치 병합 전 `terraform validate` 및 `terraform plan` 수행
- 모듈 추가/수정 시 `README` 및 예시 코드 업데이트 권장

### Terraform Plan & Apply Workflow
1. 최신 코드 Pull
`git pull origin main`

2. 코드 수정 & 포맷 정리
`terraform fmt`

3. 문법 체크
`terraform validate`

4. 변경사항 확인
`terraform plan`

5. PR 생성 및 Plan 결과 첨부

6. 리뷰 완료 후 Merge

7. 실제 적용
`terraform apply`

#### 주의 사항
- 절대 바로 `terraform apply` 하지 않는다.
	- `terraform plan` -> 코드 리뷰 -> `terraform apply` 순서
- State 파일 충돌 방지
	- 동시에 여러 명이 `terraform apply` 하지 않는다.

### PR 리뷰 체크리스트

| 체크 항목 | 설명 |
|:----------|:-----|
| terraform fmt 적용 여부 | 코드 포맷팅 적용 확인 |
| 리소스 태그 삽입 여부 | 모든 리소스에 태그 삽입 여부 확인 |
| 버전 명시 여부 | versions.tf 파일 적절히 관리 여부 확인 |
| 민감 정보 노출 여부 | Secrets 직접 노출 방지 여부 확인 |
| 가독성 및 일관성 | 들여쓰기, 정렬, 빈줄 확인 |
| 리소스 네이밍 규칙 준수 | snake_case로 일관성 있게 작성했는지 |
| 모듈 사용 여부 | 리소스를 직접 작성하지 않고 module로 감쌌는지 |
| outputs.tf 작성 여부 | 주요 출력 값(outputs)을 정의했는지 |
| terraform plan 결과 검토 | 의도치 않은 리소스 삭제/변경 없는지 확인 |
