import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { MessageListComponent } from '@/app/messages/message-list/message-list.component';
import { MessageService } from '@/app/core/message.service';
import { MessageComponent } from '@/app/messages/message/message.component';
import { of } from 'rxjs';

describe('MessageListComponent', () => {
  let component: MessageListComponent;
  let fixture: ComponentFixture<MessageListComponent>;

  beforeEach(async () => {
    const spy = jasmine.createSpyObj('MessageService', ['getMessages']);
    spy.getMessages.and.returnValue(of([]));
    spy.newMessage$ = of();

    await TestBed.configureTestingModule({
      imports: [
        MessageListComponent,
        MessageComponent,
        HttpClientTestingModule
      ],
      providers: [
        { provide: MessageService, useValue: spy }
      ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(MessageListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
