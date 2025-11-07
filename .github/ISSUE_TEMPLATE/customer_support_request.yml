name: "Customer Support Request"
description: "This is a template for requesting technical support or reporting issues while using the SDK. (SDK 사용 중 발생하는 문제나 기술 지원을 요청하기 위한 템플릿입니다.)"
title: "[Customer Request] "
labels: ["customer-request", "needs-triage"]
body:
  - type: input
    id: customer-company
    attributes:
      label: "Customer Company (요청 고객사)"
      description: "Please enter your company name."
    validations:
      required: true
  - type: group
    id: environment
    attributes:
      label: "Environment (사용 환경 정보)"
    body:
      - type: input
        id: device-model
        attributes:
          label: "Device Model (단말기 모델)"
          description: "e.g., SL20, US30"
        validations:
          required: true
      - type: input
        id: os-version
        attributes:
          label: "Android OS Version (안드로이드 OS 버전)"
          description: "e.g., 11, 13"
        validations:
          required: true
      - type: input
        id: app-version
        attributes:
          label: "Relevant App & Version (관련 앱 및 버전)"
          description: "e.g., KeyTool V1.2.6, Startup V1.2.5"
        validations:
          required: true
  - type: textarea
    id: problem-description
    attributes:
      label: "Problem to Solve (해결하고 싶은 문제)"
      description: "Please describe the business problem or the goal you are trying to achieve."
    validations:
      required: true
  - type: textarea
    id: suggested-solution
    attributes:
      label: "Suggested Solution or API Request (제안하는 해결책 또는 API 요청 사항)"
      description: "If you have a specific technical solution or API in mind, please describe it here."
    validations:
      required: false
  - type: input
    id: deadline
    attributes:
      label: "Required By Date (최소 희망 완료일)"
      description: "Please provide the date by which you need a solution. (YYYY-MM-DD)"
    validations:
      required: true
