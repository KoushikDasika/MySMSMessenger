import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, Subject, tap } from 'rxjs';
import { MessageRequest, MessageResponse } from '@/app/core/message.model';

@Injectable({
  providedIn: 'root'
})
export class MessageService {
  private newMessageSubject = new Subject<MessageResponse>();
  
  // Observable that components can subscribe to
  newMessage$ = this.newMessageSubject.asObservable();
  
  constructor(private http: HttpClient) { }
  
  getMessages(): Observable<MessageResponse[]> {
    return this.http.get<MessageResponse[]>('/api/messages', { withCredentials: true });
  }

  sendMessage({phoneNumber, messageBody}: MessageRequest): Observable<MessageResponse> {
    const headers = new HttpHeaders({
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    });

    return this.http.post<MessageResponse>('/api/messages', { to: phoneNumber, body: messageBody }, { headers, withCredentials: true })
      .pipe(
        tap((response: MessageResponse) => {
          // Emit the new message to all subscribers
          this.newMessageSubject.next(response);
        })
      );
  }
}