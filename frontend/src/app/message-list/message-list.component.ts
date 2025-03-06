import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MessageService } from '@/app/core/message.service';
import { MessageComponent } from '@/app/message/message.component';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-message-list',
  standalone: true,
  imports: [CommonModule, MessageComponent],
  templateUrl: './message-list.component.html',
  styleUrl: './message-list.component.css'
})
export class MessageListComponent implements OnInit, OnDestroy {
  messages: any[] = [];
  loading = false;
  error: string | null = null;
  private messageSubscription: Subscription | null = null;

  constructor(private messageService: MessageService) {}

  ngOnInit(): void {
    this.fetchMessages();
    
    // Subscribe to new messages
    this.messageSubscription = this.messageService.newMessage$.subscribe(newMessage => {
      // Add the new message to the messages array
      this.messages = [newMessage, ...this.messages];
    });
  }
  
  ngOnDestroy(): void {
    // Clean up subscription to prevent memory leaks
    if (this.messageSubscription) {
      this.messageSubscription.unsubscribe();
    }
  }

  fetchMessages(): void {
    this.loading = true;
    this.error = null;

    this.messageService.getMessages().subscribe({
      next: (response: any) => {
        this.messages = response;
        this.loading = false;
      },
      error: (err) => {
        console.error('Error fetching messages:', err);
        this.error = 'Failed to load messages. Please try again later.';
        this.loading = false;
      }
    });
  }
}