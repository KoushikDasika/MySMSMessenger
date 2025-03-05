import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-message-form',
  imports: [CommonModule, FormsModule],
  templateUrl: './message-form.component.html',
  styleUrl: './message-form.component.css'
})
export class MessageFormComponent {
  message = {
    phoneNumber: '',
    message: ''
  };
  
  isSubmitting = false;

  clearForm() {
    this.message = {
      phoneNumber: '',
      message: ''
    };
  }

  isFormValid(): boolean {
    return !!this.message.phoneNumber && !!this.message.message && !this.isSubmitting;
  }

  onSubmit() {
    if (!this.isFormValid()) {
      return;
    }
    
    this.isSubmitting = true;
    console.log('Message submitted:', this.message);
    
    // Simulate API call with timeout
    setTimeout(() => {
      // Handle successful submission
      this.clearForm();
      this.isSubmitting = false;
    }, 1500); // 1.5 seconds delay to simulate network request
  }
}
