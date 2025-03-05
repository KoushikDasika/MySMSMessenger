import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  constructor(private http: HttpClient) { }
  
  getMessages() {
    return this.http.get('/api/messages');
  }

  sendMessage(message: string) {
    return this.http.post('/api/messages', { message });
  }
}

