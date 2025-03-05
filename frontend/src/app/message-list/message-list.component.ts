import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MessageService } from '@/app/core/message.service';
import { MessageComponent } from '@/app/message/message.component';

@Component({
  selector: 'app-message-list',
  standalone: true,
  imports: [CommonModule, MessageComponent],
  templateUrl: './message-list.component.html',
  styleUrl: './message-list.component.css'
})
export class MessageListComponent implements OnInit {
  messages: any[] = [];
  loading = false;
  error: string | null = null;

  constructor(private messageService: MessageService) {}

  ngOnInit(): void {
    this.fetchMessages();
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