import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  constructor(private http: HttpClient) { }
  
  getMessages() {
    return this.http.get('/api/messages');
  }

  sendMessage({phoneNumber, messageBody}: {phoneNumber: string, messageBody: string}) {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });

    return this.http.post('/api/messages', { to: phoneNumber, body: messageBody }, { headers, withCredentials: true });
  }
}