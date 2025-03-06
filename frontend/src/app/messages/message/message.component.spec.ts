import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MessageComponent } from '@/app/messages/message/message.component';
import { MessageResponse } from '@/app/core/message.model';

describe('MessageComponent', () => {
  let component: MessageComponent;
  let fixture: ComponentFixture<MessageComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MessageComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MessageComponent);
    component = fixture.componentInstance;
    
    // Provide a mock message
    component.message = {
      id: '1',
      to: '+12025550123',
      body: 'Test message',
      sent_at: '2023-01-01T00:00:00Z'
    } as MessageResponse;
    
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
