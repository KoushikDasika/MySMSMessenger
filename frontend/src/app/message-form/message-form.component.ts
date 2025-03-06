import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { MessageService } from '../core/message.service';
import { FormBuilder, FormGroup, Validators, AbstractControl, ValidationErrors } from '@angular/forms';
import { ReactiveFormsModule } from '@angular/forms';
import { parsePhoneNumber, getAsYouType, AsYouType } from 'awesome-phonenumber';

@Component({
  selector: 'app-message-form',
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  templateUrl: './message-form.component.html',
  styleUrl: './message-form.component.css',
  standalone: true
})
export class MessageFormComponent {
  messageForm: FormGroup;
  readonly MAX_LENGTH = 250;
  submitting = false;
  phoneNumberFormatter: AsYouType;

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
        Validators.required,
        this.phoneNumberValidator
      ]]
    });
    
    // Initialize the AsYouType formatter
    this.phoneNumberFormatter = getAsYouType();
  }

  // Custom validator to check if phone number is valid E.164 format
  phoneNumberValidator(control: AbstractControl): ValidationErrors | null {
    const value = control.value;
    if (!value) {
      return null; // Let required validator handle empty values
    }
    
    // Parse the phone number
    const phoneNumber = parsePhoneNumber(value);
    
    // Check if it's valid and in E.164 format
    if (!phoneNumber.valid) {
      return { invalidPhoneNumber: true };
    }
    
    // Check if the number matches E.164 format (starts with + followed by digits only)
    const e164Regex = /^\+[1-9]\d{1,14}$/;
    if (!e164Regex.test(phoneNumber.number.e164)) {
      return { notE164Format: true };
    }
    
    return null;
  }
  
  // Format phone number as user types
  formatPhoneNumber(event: Event) {
    const input = event.target as HTMLInputElement;
    const value = input.value;
    
    if (value) {
      // Reset the formatter with the current value
      this.phoneNumberFormatter.reset(value);
      
      // Get the formatted value
      const formattedValue = this.phoneNumberFormatter.number();
      
      // Update the form control value with the formatted value
      this.phoneNumber?.setValue(formattedValue, { emitEvent: false });
      
      // Set the cursor position appropriately
      setTimeout(() => {
        input.selectionStart = input.selectionEnd = formattedValue.length;
      });
    }
  }
  
  // Convert to E.164 format before submission
  normalizePhoneNumber(phoneNumberValue: string): string {
    const phoneNumber = parsePhoneNumber(phoneNumberValue);
    return phoneNumber.valid ? phoneNumber.number.e164 : phoneNumberValue;
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
