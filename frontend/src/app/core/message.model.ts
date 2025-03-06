export interface MessageRequest {
  phoneNumber: string;
  messageBody: string;
}

export interface MessageResponse {
  id: string;
  phoneNumber: string;
  messageBody: string;
  status: 'sent' | 'delivered' | 'failed';
  createdAt: string;
}