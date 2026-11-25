import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/quiz_question.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepository();
});

class LessonRepository {
  static const Map<String, List<QuizQuestion>> _lessonQuestions = {
    'lesson_1_1': [
      MultipleChoiceQuestion(
        id: 'l1_1_q1',
        prompt: 'Khi gặp đồng nghiệp mới lần đầu, câu nào tự nhiên và lịch sự nhất?',
        options: [
          'It is a pleasure to meet you. I have heard great things about your team!',
          'Who are you and what is your salary here?',
          'I am fine thank you, and you?',
          'See you yesterday at the office.',
        ],
        correctIndex: 0,
        explanation:
            '"It is a pleasure to meet you" kết hợp lời khen nhẹ nhàng giúp mở đầu cuộc trò chuyện cực kỳ thiện cảm.',
      ),
      FillInTheBlankQuestion(
        id: 'l1_1_q2',
        prompt: 'Điền từ thích hợp để hỏi thăm công việc dạo này:',
        sentenceWithBlank: 'How have things been _____ with your new project lately?',
        correctAnswer: 'going',
        wordBank: ['going', 'doing', 'making', 'walking'],
        explanation:
            'Cấu trúc "How have things been going with...?" dùng để hỏi thăm tình hình công việc/cuộc sống dạo gần đây.',
      ),
      SentenceOrderingQuestion(
        id: 'l1_1_q3',
        prompt: 'Sắp xếp thành câu hỏi bắt chuyện cuối tuần:',
        vietnameseMeaning: 'Bạn có kế hoạch gì thú vị cho cuối tuần này không?',
        shuffledTokens: ['this weekend?', 'exciting plans', 'Do you', 'have any', 'for'],
        correctOrder: ['Do you', 'have any', 'exciting plans', 'for', 'this weekend?'],
        explanation:
            '"Do you have any exciting plans for this weekend?" là câu Small Talk kinh điển vào thứ Sáu.',
      ),
      ListeningDictationQuestion(
        id: 'l1_1_q4',
        prompt: 'Nghe và chép lại câu giới thiệu bản thân:',
        audioText: 'I work as a product designer in the mobile division.',
        ipaHint: '/aɪ wɜːk æz ə ˈprɒdʌkt dɪˈzaɪnər ɪn ðə ˈməʊbaɪl dɪˈvɪʒən/',
        explanation:
            'Dùng "work as a + [nghề nghiệp]" và "in the + [bộ phận] division/department".',
      ),
      SpeakingPronunciationQuestion(
        id: 'l1_1_q5',
        prompt: 'Đọc to câu chào hỏi và kết nối:',
        targetSentence: 'Let us grab a coffee sometime this week to catch up.',
        ipaTranscription: '/lɛt ʌs ɡræb ə ˈkɒfi ˈsʌmtaɪm ðɪs wiːk tuː kætʃ ʌp/',
        vietnameseTranslation: 'Tuần này lúc nào đó cùng đi uống cà phê trò chuyện nhé.',
        explanation:
            '"Grab a coffee" (đi uống cà phê nhanh) và "catch up" (trò chuyện cập nhật tình hình).',
      ),
    ],
    'lesson_1_2': [
      MultipleChoiceQuestion(
        id: 'l1_2_q1',
        prompt: 'Chọn cách gọi đồ uống lịch sự tại quán cà phê:',
        options: [
          'Could I get an iced oat milk latte, less sweet, please?',
          'Give me one iced latte now.',
          'I want coffee no sugar fast.',
          'Bring for me a cup of tea.',
        ],
        correctIndex: 0,
        explanation:
            '"Could I get a/an..., please?" hoặc "I would like..." là mẫu câu chuẩn mực khi gọi món.',
      ),
      FillInTheBlankQuestion(
        id: 'l1_2_q2',
        prompt: 'Điền từ khi nhân viên hỏi bạn uống tại quán hay mang đi:',
        sentenceWithBlank: 'Would you like that for here or to _____?',
        correctAnswer: 'go',
        wordBank: ['go', 'walk', 'run', 'leave'],
        explanation:
            '"For here or to go?" (Dùng tại quán hay mang đi?) là câu hỏi quen thuộc tại các quán cà phê.',
      ),
      SentenceOrderingQuestion(
        id: 'l1_2_q3',
        prompt: 'Sắp xếp câu xin thanh toán hóa đơn:',
        vietnameseMeaning: 'Xin lỗi, chúng tôi có thể xin hóa đơn tính tiền được không?',
        shuffledTokens: ['have the', 'Could we', 'check,', 'please?', 'Excuse me,'],
        correctOrder: ['Excuse me,', 'Could we', 'have the', 'check,', 'please?'],
        explanation:
            '"Could we have the check/bill, please?" dùng để gọi thanh toán lịch sự tại nhà hàng.',
      ),
      ListeningDictationQuestion(
        id: 'l1_2_q4',
        prompt: 'Nghe và nhập lại câu hỏi về dị ứng thực phẩm:',
        audioText: 'Does this dish contain any peanuts or dairy?',
        ipaHint: '/dʌz ðɪs dɪʃ kənˈteɪn ˈɛni ˈpiːnʌts ɔː ˈdeəri/',
        explanation:
            '"Contain" là chứa thành phần nào đó, "dairy" là các sản phẩm từ sữa.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l1_2_q5',
        prompt: 'Luyện phát âm câu thanh toán bằng thẻ:',
        targetSentence: 'Can I pay by contactless card or Apple Pay?',
        ipaTranscription: '/kæn aɪ peɪ baɪ ˈkɒntæktləs kɑːd ɔːr ˈæpl peɪ/',
        vietnameseTranslation: 'Tôi có thể thanh toán bằng thẻ chạm hoặc Apple Pay không?',
        explanation:
            'Dùng giới từ "by" với phương thức thanh toán: "pay by card / pay in cash".',
      ),
    ],
    'lesson_1_3': [
      MultipleChoiceQuestion(
        id: 'l1_3_q1',
        prompt: 'Bạn muốn hỏi chiếc áo khoác này có cỡ Medium (M) không, bạn nói thế nào?',
        options: [
          'Excuse me, do you have this jacket in a medium?',
          'Where is medium size of this shirt?',
          'Make this jacket smaller for me.',
          'How much weight is this jacket?',
        ],
        correctIndex: 0,
        explanation: '"Do you have this [item] in a [size]?" là cấu trúc chuẩn khi mua quần áo.',
      ),
      FillInTheBlankQuestion(
        id: 'l1_3_q2',
        prompt: 'Điền từ chỉ biên lai thanh toán (chú ý chữ "p" câm):',
        sentenceWithBlank: 'You will need the original _____ if you want to exchange the item.',
        correctAnswer: 'receipt',
        wordBank: ['receipt', 'recipe', 'prescription', 'ticket'],
        explanation: '"Receipt" (/rɪˈsiːt/) là biên lai mua hàng; còn "recipe" là công thức nấu ăn.',
      ),
      SentenceOrderingQuestion(
        id: 'l1_3_q3',
        prompt: 'Sắp xếp câu hỏi phòng thử đồ:',
        vietnameseMeaning: 'Tôi có thể thử chiếc áo này ở phòng thử đồ được không?',
        shuffledTokens: ['try this on', 'in the', 'fitting room?', 'Could I'],
        correctOrder: ['Could I', 'try this on', 'in the', 'fitting room?'],
        explanation: '"Try [something] on" là mặc thử quần áo/giày dép.',
      ),
      ListeningDictationQuestion(
        id: 'l1_3_q4',
        prompt: 'Nghe câu thông báo giảm giá và viết lại:',
        audioText: 'This entire collection is twenty percent off today.',
        ipaHint: '/ðɪs ɪnˈtaɪə kəˈlɛkʃən ɪz ˈtwɛnti pəˈsɛnt ɒf təˈdeɪ/',
        explanation: '"Twenty percent off" nghĩa là giảm giá 20%.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l1_3_q5',
        prompt: 'Đọc câu hỏi về chính sách hoàn tiền:',
        targetSentence: 'What is your return and refund policy for online orders?',
        ipaTranscription: '/wɒt ɪz jɔː rɪˈtɜːn ænd ˈriːfʌnd ˈpɒlɪsi fɔːr ˈɒnlaɪn ˈɔːdəz/',
        vietnameseTranslation: 'Chính sách đổi trả và hoàn tiền cho đơn hàng online của bên bạn thế nào?',
        explanation: '"Return and refund policy" là chính sách đổi trả và hoàn tiền.',
      ),
    ],
    'lesson_2_1': [
      MultipleChoiceQuestion(
        id: 'l2_1_q1',
        prompt: 'Tại quầy làm thủ tục sân bay, bạn muốn xin ghế ngồi cạnh lối đi thì nói thế nào?',
        options: [
          'Could I have an aisle seat if one is available, please?',
          'Put me on the road chair please.',
          'I want sit outside the window.',
          'Give me the hallway seat.',
        ],
        correctIndex: 0,
        explanation:
            '"Aisle seat" (/aɪl siːt/ - chữ s câm) là ghế cạnh lối đi; "Window seat" là ghế cạnh cửa sổ.',
      ),
      FillInTheBlankQuestion(
        id: 'l2_1_q2',
        prompt: 'Điền từ phù hợp tại quầy Hải quan nhập cảnh (Immigration):',
        sentenceWithBlank: 'I am visiting for a five-day technology _____ and sightseeing.',
        correctAnswer: 'conference',
        wordBank: ['conference', 'luggage', 'passport', 'terminal'],
        explanation:
            'Trả lời rõ ràng mục đích chuyến đi như "for a technology conference" (dự hội nghị công nghệ).',
      ),
      SentenceOrderingQuestion(
        id: 'l2_1_q3',
        prompt: 'Sắp xếp câu hỏi cổng lên máy bay:',
        vietnameseMeaning: 'Chuyến bay của chúng ta đã bắt đầu lên máy bay ở cổng 14 chưa?',
        shuffledTokens: ['at gate 14', 'started boarding', 'Has our', 'flight', 'yet?'],
        correctOrder: ['Has our', 'flight', 'started boarding', 'at gate 14', 'yet?'],
        explanation:
            '"Boarding" là quá trình hành khách lên máy bay, "Gate" là cổng ra máy bay.',
      ),
      ListeningDictationQuestion(
        id: 'l2_1_q4',
        prompt: 'Nghe thông báo tại sân bay và viết lại:',
        audioText: 'Please have your boarding pass and passport ready.',
        ipaHint: '/pliːz hæv jɔː ˈbɔːdɪŋ pɑːs ænd ˈpɑːspɔːt ˈrɛdi/',
        explanation: '"Boarding pass" là thẻ lên máy bay.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l2_1_q5',
        prompt: 'Đọc câu báo thất lạc hành lý ký gửi:',
        targetSentence: 'My checked baggage did not arrive on the carousel.',
        ipaTranscription: '/maɪ tʃɛkt ˈbæɡɪdʒ dɪd nɒt əˈraɪv ɒn ðə ˌkærəˈsɛl/',
        vietnameseTranslation: 'Hành lý ký gửi của tôi không thấy xuất hiện trên băng chuyền.',
        explanation:
            '"Checked baggage" là hành lý ký gửi, "carousel" là băng chuyền nhận hành lý.',
      ),
    ],
    'lesson_2_2': [
      MultipleChoiceQuestion(
        id: 'l2_2_q1',
        prompt: 'Khi đến quầy lễ tân khách sạn nhận phòng đã đặt trước, bạn nói câu nào?',
        options: [
          'Hello, I would like to check in. I have a reservation under the name Minh Anh.',
          'Hello, give me one bed room tonight.',
          'I am booking a hotel yesterday name Minh Anh.',
          'Open the room door for me please.',
        ],
        correctIndex: 0,
        explanation: '"I have a reservation under the name [Tên]" là câu chuẩn xác nhất khi check-in.',
      ),
      FillInTheBlankQuestion(
        id: 'l2_2_q2',
        prompt: 'Điền từ có nghĩa là "miễn phí đi kèm dịch vụ phòng":',
        sentenceWithBlank: 'Our hotel offers a _____ buffet breakfast from 6:30 to 10:00 AM.',
        correctAnswer: 'complimentary',
        wordBank: ['complimentary', 'expensive', 'temporary', 'mandatory'],
        explanation: '"Complimentary" trong khách sạn/hàng không có nghĩa là miễn phí tặng kèm.',
      ),
      SentenceOrderingQuestion(
        id: 'l2_2_q3',
        prompt: 'Sắp xếp câu xin trả phòng muộn:',
        vietnameseMeaning: 'Tôi có thể xin trả phòng muộn vào lúc 1 giờ chiều được không?',
        shuffledTokens: ['a late checkout', 'request', 'Could I', 'at 1 PM?'],
        correctOrder: ['Could I', 'request', 'a late checkout', 'at 1 PM?'],
        explanation: '"Request a late checkout" là yêu cầu trả phòng muộn.',
      ),
      ListeningDictationQuestion(
        id: 'l2_2_q4',
        prompt: 'Nghe câu báo hỏng điều hòa trong phòng:',
        audioText: 'The air conditioning in my room is not working properly.',
        ipaHint: '/ði eə kənˈdɪʃənɪŋ ɪn maɪ ruːm ɪz nɒt ˈwɜːkɪŋ ˈprɒpəli/',
        explanation: '"Not working properly" nghĩa là hoạt động không bình thường.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l2_2_q5',
        prompt: 'Đọc câu gửi hành lý ở quầy lễ tân:',
        targetSentence: 'Could we leave our luggage at the front desk until evening?',
        ipaTranscription: '/kʊd wiː liːv ˈaʊə ˈlʌɡɪdʒ æt ðə frʌnt dɛsk ənˈtɪl ˈiːvnɪŋ/',
        vietnameseTranslation: 'Chúng tôi có thể gửi hành lý ở quầy lễ tân đến tối được không?',
        explanation: '"Front desk" là quầy lễ tân khách sạn.',
      ),
    ],
    'lesson_3_1': [
      MultipleChoiceQuestion(
        id: 'l3_1_q1',
        prompt: 'Chọn cách diễn đạt tự nhiên nhất khi cập nhật tiến độ trong buổi họp Daily Standup:',
        options: [
          'I am currently working on integrating the payment gateway.',
          'I am currently work for integrate the payment gateway.',
          'Yesterday I will finish the payment gateway.',
          'I have been finished the payment gateway tomorrow.',
        ],
        correctIndex: 0,
        explanation:
            'Cấu trúc "be currently working on + V-ing/Noun" dùng để mô tả công việc đang triển khai.',
      ),
      FillInTheBlankQuestion(
        id: 'l3_1_q2',
        prompt: 'Điền từ phù hợp vào chỗ trống:',
        sentenceWithBlank:
            'We ran into a minor technical _____, but it should be resolved by this afternoon.',
        correctAnswer: 'blocker',
        wordBank: ['blocker', 'deadline', 'agenda', 'milestone'],
        explanation:
            '"Technical blocker" là thuật ngữ chỉ trở ngại kỹ thuật làm gián đoạn tiến độ dự án.',
      ),
      SentenceOrderingQuestion(
        id: 'l3_1_q3',
        prompt: 'Sắp xếp các từ sau thành câu hoàn chỉnh:',
        vietnameseMeaning: 'Chúng ta có thể dời lịch họp sang thứ Năm được không?',
        shuffledTokens: ['Thursday?', 'Could', 'the meeting', 'reschedule', 'we', 'to'],
        correctOrder: ['Could', 'we', 'reschedule', 'the meeting', 'to', 'Thursday?'],
        explanation:
            '"Could we reschedule [something] to [time]?" là mẫu câu lịch sự để xin dời lịch hẹn.',
      ),
      ListeningDictationQuestion(
        id: 'l3_1_q4',
        prompt: 'Nghe câu phát âm và nhập lại chính xác:',
        audioText: 'Let us align on the top priorities for this sprint.',
        ipaHint: '/lɛt ʌs əˈlaɪn ɒn ðə tɒp praɪˈɒrɪtiz fɔː ðɪs sprɪnt/',
        explanation: '"Align on the top priorities" nghĩa là thống nhất về các ưu tiên quan trọng nhất.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l3_1_q5',
        prompt: 'Đọc to câu sau để AI chấm điểm phát âm:',
        targetSentence: 'I completely agree with your perspective on this.',
        ipaTranscription: '/aɪ kəmˈpliːtli əˈɡriː wɪð jɔː pəˈspɛktɪv ɒn ðɪs/',
        vietnameseTranslation: 'Tôi hoàn toàn đồng ý với góc nhìn của bạn về vấn đề này.',
        explanation: 'Chú ý nhấn trọng âm ở "com-PLETE-ly", "a-GREE" và "per-SPEC-tive".',
      ),
    ],
    'lesson_3_2': [
      MultipleChoiceQuestion(
        id: 'l3_2_q1',
        prompt: 'Cách phản biện nào lịch sự và chuyên nghiệp nhất trong cuộc họp?',
        options: [
          'I see your point, but from a technical perspective, we might need more time for testing.',
          'That idea is bad and impossible to code.',
          'You do not understand how software works.',
          'No, we will never do that.',
        ],
        correctIndex: 0,
        explanation: '"I see your point, but from a [X] perspective..." giúp phản biện mang tính xây dựng.',
      ),
      FillInTheBlankQuestion(
        id: 'l3_2_q2',
        prompt: 'Điền động từ có nghĩa là "giải thích chi tiết hơn":',
        sentenceWithBlank: 'That sounds promising! Could you _____ a bit more on the budget estimate?',
        correctAnswer: 'elaborate',
        wordBank: ['elaborate', 'hesitate', 'celebrate', 'eliminate'],
        explanation: '"Elaborate on something" (/ɪˈlæbəreɪt/) là trình bày kỹ hơn về điều gì.',
      ),
      SentenceOrderingQuestion(
        id: 'l3_2_q3',
        prompt: 'Sắp xếp câu hỏi về tính khả thi của kế hoạch:',
        vietnameseMeaning: 'Việc ra mắt tính năng này vào tháng tới có khả thi không?',
        shuffledTokens: ['next month?', 'to launch', 'this feature', 'Is it', 'feasible'],
        correctOrder: ['Is it', 'feasible', 'to launch', 'this feature', 'next month?'],
        explanation: '"Is it feasible to + V?" dùng để hỏi tính khả thi của kế hoạch.',
      ),
      ListeningDictationQuestion(
        id: 'l3_2_q4',
        prompt: 'Nghe câu đề xuất giải pháp thay thế:',
        audioText: 'What if we focus on the core features first?',
        ipaHint: '/wɒt ɪf wiː ˈfəʊkəs ɒn ðə kɔː ˈfiːtʃəz fɜːst/',
        explanation: '"What if we + V...?" là cách đưa ra gợi ý nhẹ nhàng, khuyến khích thảo luận.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l3_2_q5',
        prompt: 'Đọc câu tổng kết các đầu việc sau cuộc họp:',
        targetSentence: 'Let us summarize the key action items before we wrap up.',
        ipaTranscription: '/lɛt ʌs ˈsʌməraɪz ðə kiː ˈækʃən ˈaɪtəmz bɪˈfɔː wiː ræp ʌp/',
        vietnameseTranslation: 'Hãy tóm tắt lại các đầu việc chính trước khi kết thúc cuộc họp nhé.',
        explanation: '"Action items" là đầu việc cần làm; "wrap up" là khép lại buổi họp.',
      ),
    ],
    'lesson_4_1': [
      MultipleChoiceQuestion(
        id: 'l4_1_q1',
        prompt: 'Câu trả lời phỏng vấn nào thuyết phục nhất theo phương pháp STAR?',
        options: [
          'I redesigned our caching layer, which reduced API response time by 45% for 200,000 daily users.',
          'I worked very hard every day and my boss liked me.',
          'I know how to write code in many languages.',
          'My team did a project last year and it was okay.',
        ],
        correctIndex: 0,
        explanation: 'Nêu rõ Hành động cụ thể và Kết quả định lượng bằng con số (reduced by 45%).',
      ),
      FillInTheBlankQuestion(
        id: 'l4_1_q2',
        prompt: 'Điền từ chỉ sự phối hợp liên phòng ban:',
        sentenceWithBlank: 'I closely _____ with product managers and QA engineers throughout the release.',
        correctAnswer: 'collaborated',
        wordBank: ['collaborated', 'competed', 'complained', 'hesitated'],
        explanation: '"Collaborate with..." thể hiện kỹ năng làm việc nhóm chuyên nghiệp.',
      ),
      SentenceOrderingQuestion(
        id: 'l4_1_q3',
        prompt: 'Sắp xếp câu đàm phán đãi ngộ:',
        vietnameseMeaning: 'Dựa trên kinh nghiệm của mình, tôi kỳ vọng mức thu nhập cạnh tranh.',
        shuffledTokens: [
          'a competitive',
          'Based on',
          'my experience,',
          'I am looking for',
          'compensation package.',
        ],
        correctOrder: [
          'Based on',
          'my experience,',
          'I am looking for',
          'a competitive',
          'compensation package.',
        ],
        explanation: '"Compensation package" bao gồm lương cứng, thưởng và phúc lợi.',
      ),
      ListeningDictationQuestion(
        id: 'l4_1_q4',
        prompt: 'Nghe câu hỏi phỏng vấn về áp lực thời gian:',
        audioText: 'How do you handle tight deadlines under high pressure?',
        ipaHint: '/haʊ duː juː ˈhændl taɪt ˈdɛdlaɪnz ˈʌndə haɪ ˈprɛʃə/',
        explanation: '"Handle tight deadlines under high pressure" là xử lý hạn chót dưới áp lực cao.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l4_1_q5',
        prompt: 'Luyện nói câu giới thiệu thế mạnh cốt lõi:',
        targetSentence: 'My core strength is building scalable and user-friendly applications.',
        ipaTranscription: '/maɪ kɔː strɛŋθ ɪz ˈbɪldɪŋ ˈskeɪləbl ænd ˈjuːzə ˈfrɛndli ˌæplɪˈkeɪʃənz/',
        vietnameseTranslation: 'Thế mạnh cốt lõi của tôi là xây dựng các ứng dụng mở rộng tốt và thân thiện.',
        explanation: '"Core strength" là điểm mạnh cốt lõi; "scalable" là mở rộng quy mô tốt.',
      ),
    ],
    'lesson_5_1': [
      MultipleChoiceQuestion(
        id: 'l5_1_q1',
        prompt: 'Câu nào thể hiện tư duy quản trị rủi ro tốt nhất khi thuyết trình dự án?',
        options: [
          'To mitigate potential delays, we have prepared a fallback contingency plan.',
          'Nothing bad will ever happen to our project.',
          'If the server crashes, we will just wait and see.',
          'We do not need any testing before release.',
        ],
        correctIndex: 0,
        explanation: '"Mitigate potential delays" kết hợp "contingency plan" thể hiện sự chuẩn bị kỹ lưỡng.',
      ),
      FillInTheBlankQuestion(
        id: 'l5_1_q2',
        prompt: 'Điền từ chỉ cột mốc quan trọng của dự án:',
        sentenceWithBlank: 'Launching the offline learning mode is our biggest _____ this quarter.',
        correctAnswer: 'milestone',
        wordBank: ['milestone', 'obstacle', 'accident', 'souvenir'],
        explanation: '"Milestone" là cột mốc đánh dấu bước tiến lớn trong dự án.',
      ),
      SentenceOrderingQuestion(
        id: 'l5_1_q3',
        prompt: 'Sắp xếp câu trình bày giá trị dài hạn:',
        vietnameseMeaning: 'Sáng kiến này sẽ mang lại giá trị lâu dài đáng kể cho người dùng.',
        shuffledTokens: [
          'long-term value',
          'will deliver',
          'substantial',
          'This initiative',
          'to our users.',
        ],
        correctOrder: [
          'This initiative',
          'will deliver',
          'substantial',
          'long-term value',
          'to our users.',
        ],
        explanation: '"Deliver substantial long-term value" là mang lại giá trị lâu dài đáng kể.',
      ),
      ListeningDictationQuestion(
        id: 'l5_1_q4',
        prompt: 'Nghe câu báo cáo đúng tiến độ mục tiêu quý:',
        audioText: 'We are currently on track to meet all quarterly objectives.',
        ipaHint: '/wiː ɑː ˈkʌrəntli ɒn træk tuː miːt ɔːl ˈkwɔːtəli əbˈdʒɛktɪvz/',
        explanation: '"Be on track" nghĩa là đang đi đúng tiến độ kế hoạch.',
      ),
      SpeakingPronunciationQuestion(
        id: 'l5_1_q5',
        prompt: 'Luyện nói câu phân bổ nguồn lực kỹ thuật:',
        targetSentence: 'We should allocate more engineering resources to high-impact features.',
        ipaTranscription: '/wiː ʃʊd ˈæləkeɪt mɔːr ˌɛndʒɪˈnɪərɪŋ rɪˈzɔːsɪz tuː haɪ ˈɪmpækt ˈfiːtʃəz/',
        vietnameseTranslation: 'Chúng ta nên phân bổ thêm nguồn lực kỹ thuật cho các tính năng tác động cao.',
        explanation: '"Allocate resources" (/ˈæləkeɪt/) là phân bổ nguồn lực.',
      ),
    ],
    'lesson_6_1': [
      MultipleChoiceQuestion(
        id: 'l6_1_q1',
        prompt: 'Từ vựng C1 nào có nghĩa là "hiện diện ở khắp mọi nơi, cực kỳ phổ biến"?',
        options: ['Ubiquitous', 'Scarce', 'Negligible', 'Obsolete'],
        correctIndex: 0,
        explanation: '"Ubiquitous" (/juːˈbɪkwɪtəs/) nghĩa là có mặt ở khắp nơi.',
      ),
      FillInTheBlankQuestion(
        id: 'l6_1_q2',
        prompt: 'Điền thành ngữ mang nghĩa "tập trung vào bức tranh tổng thể":',
        sentenceWithBlank: 'Instead of arguing over minor UI colors, we need to focus on the big _____.',
        correctAnswer: 'picture',
        wordBank: ['picture', 'photo', 'painting', 'mirror'],
        explanation: 'Idiom "focus on the big picture" nghĩa là nhìn vào bức tranh lớn.',
      ),
      SentenceOrderingQuestion(
        id: 'l6_1_q3',
        prompt: 'Sắp xếp câu lập luận học thuật IELTS:',
        vietnameseMeaning: 'Trí tuệ nhân tạo đóng vai trò then chốt trong việc cá nhân hóa giáo dục.',
        shuffledTokens: [
          'in personalizing',
          'plays a pivotal role',
          'Artificial intelligence',
          'modern education.',
        ],
        correctOrder: [
          'Artificial intelligence',
          'plays a pivotal role',
          'in personalizing',
          'modern education.',
        ],
        explanation: '"Play a pivotal role in + V-ing" là cụm từ ăn điểm cao trong IELTS.',
      ),
      ListeningDictationQuestion(
        id: 'l6_1_q4',
        prompt: 'Nghe và viết lại câu thành ngữ công sở:',
        audioText: 'Let us touch base tomorrow to make sure we are on the same page.',
        ipaHint: '/lɛt ʌs tʌtʃ beɪs təˈmɒrəʊ tuː meɪk ʃʊə wiː ɑːr ɒn ðə seɪm peɪdʒ/',
        explanation: '"Touch base" (liên hệ cập nhật) và "on the same page" (hiểu thống nhất).',
      ),
      SpeakingPronunciationQuestion(
        id: 'l6_1_q5',
        prompt: 'Luyện phát âm câu học thuật C1:',
        targetSentence: 'Lifelong learning is indispensable in a rapidly evolving digital economy.',
        ipaTranscription: '/ˈlaɪflɒŋ ˈlɜːnɪŋ ɪz ˌɪndɪˈspɛnsəbl ɪn ə ˈræpɪdli ɪˈvɒlvɪŋ ˈdɪdʒɪtl ɪˈkɒnəmi/',
        vietnameseTranslation: 'Học tập suốt đời là không thể thiếu trong nền kinh tế số biến đổi nhanh.',
        explanation: '"Indispensable" (/ˌɪndɪˈspɛnsəbl/) là không thể thiếu được (C1).',
      ),
    ],
  };

  List<QuizQuestion> getQuestionsForLesson(String lessonId) {
    return _lessonQuestions[lessonId] ?? _lessonQuestions['lesson_3_1']!;
  }
}
