# REST_TODO

## Introduce

REST API 를 사용하여 나만의 할 일을 만들 수 있습니다.

## Schedule

- 개발 일정 : 2024.05.16 - 2024.05.23 (1주일)

## Development Environment & Libraries

![Swift](https://img.shields.io/badge/Swift-5.10-blue.svg) ![iOS](https://img.shields.io/badge/Platform-iOS-red.svg)

### Deployment Target

- 16.0.0

### Libraries

|   이름   |     목적     | 사용 버전 |
| :------: | :----------: | :-------: |
| SQLLite3 | 로컬 DB 저장 | iOS 16.0  |
| Combine  | 이벤트 처리  |     -     |

## Features

|                                                  할일 조회                                                   |                                                  할일 생성                                                   |                                                  할일 검색                                                   |
| :----------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------: | :----------------------------------------------------------------------------------------------------------: |
| <img src="https://velog.velcdn.com/images/jakkujakku98/post/99719843-fbb6-40bb-a283-35241f16772c/image.gif"> | <img src="https://velog.velcdn.com/images/jakkujakku98/post/01e08646-fb7f-458e-99fb-dd863fcb1fac/image.gif"> | <img src="https://velog.velcdn.com/images/jakkujakku98/post/69df556b-c75e-4373-8d0e-61337152ada8/image.gif"> |
|                                        - 최신 ToDo 데이터들 조회<br/>                                        |                                           - ToDo 데이터 생성<br/>                                            |                                  - 검색어와 일치하는 ToDo 데이터 조회<br/>                                   |
|                                            **완료된 할일 숨기기**                                            |                                                **할일 수정**                                                 |                                                **할일 삭제**                                                 |
| <img src="https://velog.velcdn.com/images/jakkujakku98/post/3b6d7623-153e-4753-97ef-2f05bdccf1e9/image.gif"> | <img src="https://velog.velcdn.com/images/jakkujakku98/post/7d993b09-fca9-4932-a507-3411f723d6ed/image.gif"> | <img src="https://velog.velcdn.com/images/jakkujakku98/post/ba1d8861-0665-41b0-a2a4-3e505a56a01c/image.gif"> |
|                                    - 완료되지 않은 ToDo 데이터 조회<br/>                                     |                                       - ToDo 데이터 내용 업데이트<br/>                                       |                                           - ToDo 데이터 삭제<br/>                                            |
|                                              **무한 스크롤링**                                               |                                                                                                              |                                                                                                              |
| <img src="https://velog.velcdn.com/images/jakkujakku98/post/6d670d85-d23c-4d05-b820-d5fd1de420ea/image.gif"> |                                                                                                              |                                                                                                              |
|                                 - 아래 스크롤시, ToDo 데이터 추가 조회<br/>                                  |                                                                                                              |                                                                                                              |
