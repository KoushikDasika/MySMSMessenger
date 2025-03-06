import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../core/message.service';

@Component({
  selector: 'app-message-form',
  imports: [CommonModule, FormsModule],
  providers: [MessageService],
  templateUrl: './message-form.component.html',
  styleUrl: './message-form.component.css'
})
export class MessageFormComponent {
  message = {
    phoneNumber: '',
    messageBody: ''
  };
  
  isSubmitting = false;

  // Inject the MessageService via constructor
  constructor(private messageService: MessageService) {}

  clearForm() {
    this.message = {
      phoneNumber: '',
      messageBody: ''
    };
  }

  isFormValid(): boolean {
    return !!this.message.phoneNumber && !!this.message.messageBody && !this.isSubmitting;
  }

  onSubmit() {
    if (!this.isFormValid()) {
      return;
    }
    
    this.isSubmitting = true;
    console.log('Message submitted:', this.message);
    
    // Use the actual service instead of setTimeout
      this.messageService.sendMessage(this.message).subscribe({
      next: () => {
        this.clearForm();
        this.isSubmitting = false;
      },
      error: (error) => {
        console.error('Error sending message:', error);
        this.isSubmitting = false;
      }
    });
  }
}
