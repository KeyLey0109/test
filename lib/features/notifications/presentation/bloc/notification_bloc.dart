import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationLoading()) {
    on<LoadNotifications>((event, emit) async {
      emit(NotificationLoading());

      // Giả lập lấy dữ liệu từ Repository
      await Future.delayed(const Duration(seconds: 1));

      // QUAN TRỌNG: Phải emit Loaded để HomePage nhận được dữ liệu và ngừng xoay
      emit(const NotificationLoaded([]));
    });

    on<MarkAsRead>((event, emit) {
      if (state is NotificationLoaded) {
        final currentNotifications =
            (state as NotificationLoaded).notifications;
        final updatedList = currentNotifications.map((n) {
          return n.id == event.notificationId ? n.copyWith(isRead: true) : n;
        }).toList();
        emit(NotificationLoaded(updatedList));
      }
    });

    on<NotificationReceived>((event, emit) {
      if (state is NotificationLoaded) {
        // Lấy danh sách hiện tại
        final currentList = (state as NotificationLoaded).notifications;
        // Chèn thông báo mới nhất lên đầu danh sách
        final newList = <NotificationEntity>[
          event.notification,
          ...currentList
        ];
        emit(NotificationLoaded(newList));
      } else {
        // Nếu danh sách chưa được khởi tạo, tạo mới
        emit(NotificationLoaded([event.notification]));
      }
    });
  }
}
