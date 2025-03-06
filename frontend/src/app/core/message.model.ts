export interface MessageRequest {
  phoneNumber: string;
  messageBody: string;
}

export interface MessageResponse {
  to: string;
  body: string;
  sent_at: string;
}