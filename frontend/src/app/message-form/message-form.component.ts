import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../core/message.service';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-message-form',
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  providers: [MessageService],
  templateUrl: './message-form.component.html',
  styleUrl: './message-form.component.css',
  standalone: true
})
export class MessageFormComponent {
  messageForm: FormGroup;
  readonly MAX_LENGTH = 250;
  submitting = false;

  constructor(
    private fb: FormBuilder,
    private messageService: MessageService
  ) {
    this.messageForm = this.fb.group({
      body: ['', [
        Validators.required,
        Validators.maxLength(this.MAX_LENGTH)
      ]],
      phoneNumber: ['', [
        Validators.required
      ]]
    });
  }

  get body() {
    return this.messageForm.get('body');
  }
  
  get phoneNumber() {
    return this.messageForm.get('phoneNumber');
  }
  
  clearForm() {
    this.messageForm.reset();
  }
  
  onSubmit() {
    if (this.submitting) return;
    
    this.messageForm.markAllAsTouched();
    
    if (this.messageForm.valid) {
      this.submitting = true;
      
      // Map form values to match the original structure
      const messageData = {
        phoneNumber: this.phoneNumber?.value,
        messageBody: this.body?.value
      };
      
      console.log('Form submitted:', messageData);
      
      this.messageService.sendMessage(messageData).subscribe({
        next: (response) => {
          console.log('Message sent successfully', response);
          this.messageForm.reset();
          this.submitting = false;
        },
        error: (error) => {
          console.error('Error sending message', error);
          this.submitting = false;
        }
      });
    }
  }
}
