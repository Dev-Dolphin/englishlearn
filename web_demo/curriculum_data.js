// ============================================================================
// LINGOAI ENGLISH - 100% OFFLINE HARDCODED CURRICULUM DATABASE
// ============================================================================

window.OFFLINE_CURRICULUM = {
  placementQuestions: [
    {
      level: 'A1',
      question: 'Chọn câu trả lời tự nhiên nhất:\n"How often do you practice speaking English?"',
      options: [
        'I practice every morning for fifteen minutes.',
        'I am practice yesterday morning.',
        'Since fifteen minutes ago.',
        'Yes, I very like English.'
      ],
      correctIndex: 0
    },
    {
      level: 'A2',
      question: 'Hoàn thành câu tại sân bay:\n"Could I have an _____ seat instead of a window seat, please?"',
      options: ['aisle', 'island', 'alley', 'angle'],
      correctIndex: 0
    },
    {
      level: 'B1',
      question: 'Chọn câu đúng ngữ pháp (Câu điều kiện loại 3):\n"If I _____ about the blocker earlier, I would have escalated it to the team."',
      options: ['knew', 'have known', 'had known', 'would know'],
      correctIndex: 2
    },
    {
      level: 'B2',
      question: 'Chọn thành ngữ (Idiom) phù hợp trong cuộc họp:\n"Before we start development, let\'s make sure all stakeholders are _____."',
      options: [
        'on the same page',
        'in the same book',
        'under the same paper',
        'at the same line'
      ],
      correctIndex: 0
    }
  ],

  units: [
    {
      id: 'unit_1',
      unitNumber: 1,
      cefrLevel: 'A1-A2',
      title: 'Giao tiếp Hàng ngày & Phản xạ Cơ bản',
      description: 'Làm chủ các tình huống chào hỏi, bắt chuyện Small Talk, gọi đồ uống và mua sắm.',
      lessons: [
        {
          id: 'lesson_1_1',
          title: 'Greetings & Small Talk',
          subtitle: 'Chào hỏi tự nhiên, bắt chuyện & kết nối bạn mới',
          xpReward: 25,
          grammarNote: 'Sử dụng thì Hiện tại hoàn thành tiếp diễn "How have things been going?" để hỏi thăm tình hình gần đây một cách tự nhiên hơn "How are you?".',
          keyVocab: [
            { word: 'Pleasure', ipa: '/ˈplɛʒə/', meaning: 'Niềm vinh hạnh, rất vui', example: 'It is a pleasure to finally meet you in person.' },
            { word: 'Catch up', ipa: '/kætʃ ʌp/', meaning: 'Trò chuyện cập nhật tình hình', example: 'Let us grab a coffee this week to catch up.' },
            { word: 'Division', ipa: '/dɪˈvɪʒən/', meaning: 'Bộ phận, khối (trong công ty)', example: 'She works in the mobile product division.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Khi gặp đồng nghiệp hoặc đối tác mới lần đầu, câu nào tự nhiên và lịch sự nhất?',
              options: [
                'It is a pleasure to meet you. I have heard great things about your team!',
                'Who are you and what is your salary here?',
                'I am fine thank you, and you?',
                'See you yesterday at the office.'
              ],
              correctIndex: 0,
              explanation: '"It is a pleasure to meet you" kết hợp lời khen nhẹ nhàng giúp mở đầu cuộc trò chuyện (Small Talk) cực kỳ thiện cảm.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ thích hợp để hỏi thăm công việc dạo này:',
              sentence: 'How have things been _____ with your new project lately?',
              correctAnswer: 'going',
              wordBank: ['going', 'doing', 'making', 'walking'],
              explanation: 'Cấu trúc "How have things been going with...?" dùng để hỏi thăm công việc/cuộc sống dạo gần đây.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp các từ thành câu hỏi bắt chuyện cuối tuần:',
              vietnameseMeaning: 'Bạn có kế hoạch gì thú vị cho cuối tuần này không?',
              shuffledTokens: ['this weekend?', 'exciting plans', 'Do you', 'have any', 'for'],
              correctOrder: ['Do you', 'have any', 'exciting plans', 'for', 'this weekend?'],
              explanation: '"Do you have any exciting plans for this weekend?" là câu Small Talk kinh điển vào chiều thứ Sáu.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu phát âm và nhập lại chính xác:',
              audioText: 'I work as a product designer in the mobile division.',
              ipaHint: '/aɪ wɜːk æz ə ˈprɒdʌkt dɪˈzaɪnər ɪn ðə ˈməʊbaɪl dɪˈvɪʒən/',
              explanation: 'Dùng "work as a + [nghề nghiệp]" và "in the + [tên bộ phận] division/department".'
            },
            {
              type: 'speaking',
              prompt: 'Đọc to câu rủ bạn đi uống cà phê trò chuyện:',
              targetSentence: 'Let us grab a coffee sometime this week to catch up.',
              ipaTranscription: '/lɛt ʌs ɡræb ə ˈkɒfi ˈsʌmtaɪm ðɪs wiːk tuː kætʃ ʌp/',
              vietnameseTranslation: 'Tuần này lúc nào đó cùng đi uống cà phê trò chuyện nhé.',
              explanation: '"Grab a coffee" (đi uống cà phê nhanh) và "catch up" (hàn huyên, cập nhật tình hình).'
            }
          ]
        },
        {
          id: 'lesson_1_2',
          title: 'Ordering at a Café & Restaurant',
          subtitle: 'Gọi đồ uống, tùy chỉnh lượng đường/đá & thanh toán',
          xpReward: 30,
          grammarNote: 'Dùng "Could I get..." hoặc "I\'d like..." thay vì "Give me..." hoặc "I want..." khi gọi món để thể hiện sự lịch sự.',
          keyVocab: [
            { word: 'For here or to go', ipa: '/fɔː hɪər ɔː tuː ɡəʊ/', meaning: 'Dùng tại quán hay mang đi', example: 'Would you like your iced latte for here or to go?' },
            { word: 'Dairy-free', ipa: '/ˈdeəri friː/', meaning: 'Không chứa sữa động vật', example: 'Do you have any dairy-free milk alternatives like oat milk?' },
            { word: 'Contactless', ipa: '/ˈkɒntæktləs/', meaning: 'Thanh toán một chạm', example: 'You can tap your contactless card on the reader.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Chọn cách gọi đồ uống lịch sự nhất tại quán cà phê:',
              options: [
                'Could I get an iced oat milk latte, less sweet, please?',
                'Give me one coffee no sugar now.',
                'I want drink hot tea fast.',
                'Bring for me a cup of water.'
              ],
              correctIndex: 0,
              explanation: '"Could I get a/an..., please?" kèm yêu cầu "less sweet" (ít ngọt) rất tự nhiên.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ khi nhân viên hỏi bạn dùng tại chỗ hay mang đi:',
              sentence: 'Would you like your order for here or to _____?',
              correctAnswer: 'go',
              wordBank: ['go', 'walk', 'run', 'leave'],
              explanation: '"For here or to go?" là mẫu câu chuẩn tại các chuỗi cà phê và nhà hàng.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu xin hóa đơn thanh toán:',
              vietnameseMeaning: 'Xin lỗi, chúng tôi có thể xin hóa đơn tính tiền được không?',
              shuffledTokens: ['have the', 'Could we', 'check,', 'please?', 'Excuse me,'],
              correctOrder: ['Excuse me,', 'Could we', 'have the', 'check,', 'please?'],
              explanation: '"Could we have the check/bill, please?" dùng khi gọi tính tiền tại nhà hàng.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu hỏi về thành phần dị ứng trong món ăn:',
              audioText: 'Does this dish contain any peanuts or dairy?',
              ipaHint: '/dʌz ðɪs dɪʃ kənˈteɪn ˈɛni ˈpiːnʌts ɔː ˈdeəri/',
              explanation: '"Contain" nghĩa là chứa thành phần nào đó; "dairy" là sản phẩm từ sữa.'
            },
            {
              type: 'speaking',
              prompt: 'Luyện phát âm câu hỏi thanh toán bằng thẻ chạm:',
              targetSentence: 'Can I pay by contactless card or Apple Pay?',
              ipaTranscription: '/kæn aɪ peɪ baɪ ˈkɒntæktləs kɑːd ɔːr ˈæpl peɪ/',
              vietnameseTranslation: 'Tôi có thể thanh toán bằng thẻ chạm hoặc Apple Pay không?',
              explanation: 'Dùng giới từ "by" cho phương thức thanh toán: "pay by card", nhưng "pay in cash".'
            }
          ]
        },
        {
          id: 'lesson_1_3',
          title: 'Shopping & Asking for Prices',
          subtitle: 'Hỏi kích cỡ, phòng thử đồ & chính sách đổi trả',
          xpReward: 30,
          grammarNote: 'Dùng "Do you have this in + [size/color]?" để hỏi kích cỡ hoặc màu sắc khác của sản phẩm.',
          keyVocab: [
            { word: 'Fitting room', ipa: '/ˈfɪtɪŋ ruːm/', meaning: 'Phòng thử đồ', example: 'Where is the fitting room, please?' },
            { word: 'Refund', ipa: '/ˈriːfʌnd/', meaning: 'Hoàn tiền', example: 'Can I get a full refund if it does not fit?' },
            { word: 'Receipt', ipa: '/rɪˈsiːt/', meaning: 'Hóa đơn biên lai (âm p câm)', example: 'Please keep your receipt for exchanges within 14 days.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Bạn muốn hỏi chiếc áo khoác này có cỡ Medium (M) không, bạn nói thế nào?',
              options: [
                'Excuse me, do you have this jacket in a medium?',
                'Where is medium size of this shirt?',
                'Make this jacket smaller for me.',
                'How much weight is this jacket?'
              ],
              correctIndex: 0,
              explanation: '"Do you have this [item] in a [size] / in [color]?" là cấu trúc chuẩn khi mua quần áo.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ chỉ biên lai thanh toán (chú ý chữ "p" câm):',
              sentence: 'You will need the original _____ if you want to exchange the item.',
              correctAnswer: 'receipt',
              wordBank: ['receipt', 'recipe', 'prescription', 'ticket'],
              explanation: '"Receipt" (/rɪˈsiːt/) là biên lai mua hàng; còn "recipe" (/ˈrɛsɪpi/) là công thức nấu ăn.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu hỏi phòng thử đồ:',
              vietnameseMeaning: 'Tôi có thể thử chiếc áo này ở phòng thử đồ được không?',
              shuffledTokens: ['try this on', 'in the', 'fitting room?', 'Could I'],
              correctOrder: ['Could I', 'try this on', 'in the', 'fitting room?'],
              explanation: '"Try [something] on" là mặc thử quần áo/giày dép.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu thông báo giảm giá và viết lại:',
              audioText: 'This entire collection is twenty percent off today.',
              ipaHint: '/ðɪs ɪnˈtaɪə kəˈlɛkʃən ɪz ˈtwɛnti pəˈsɛnt ɒf təˈdeɪ/',
              explanation: '"Twenty percent off" nghĩa là giảm giá 20%.'
            },
            {
              type: 'speaking',
              prompt: 'Đọc câu hỏi về chính sách hoàn tiền:',
              targetSentence: 'What is your return and refund policy for online orders?',
              ipaTranscription: '/wɒt ɪz jɔː rɪˈtɜːn ænd ˈriːfʌnd ˈpɒlɪsi fɔːr ˈɒnlaɪn ˈɔːdəz/',
              vietnameseTranslation: 'Chính sách đổi trả và hoàn tiền cho đơn hàng online của bên bạn như thế nào?',
              explanation: '"Return and refund policy" là chính sách đổi trả và hoàn tiền.'
            }
          ]
        }
      ]
    },
    {
      id: 'unit_2',
      unitNumber: 2,
      cefrLevel: 'A2-B1',
      title: 'Du lịch Quốc tế, Sân bay & Khách sạn',
      description: 'Tự tin làm thủ tục bay, nhập cảnh hải quan, nhận phòng khách sạn và di chuyển.',
      lessons: [
        {
          id: 'lesson_2_1',
          title: 'Airport Check-in & Immigration',
          subtitle: 'Làm thủ tục bay, chọn ghế ngồi & trả lời hải quan',
          xpReward: 35,
          grammarNote: 'Tại quầy Hải quan (Immigration), luôn trả lời ngắn gọn, rõ ràng về mục đích chuyến đi (for business / for leisure) và thời gian lưu trú.',
          keyVocab: [
            { word: 'Aisle seat', ipa: '/aɪl siːt/', meaning: 'Ghế ngồi cạnh lối đi (chữ s câm)', example: 'Could I have an aisle seat near the front?' },
            { word: 'Boarding pass', ipa: '/ˈbɔːdɪŋ pɑːs/', meaning: 'Thẻ lên máy bay', example: 'Your gate number is printed on your boarding pass.' },
            { word: 'Carousel', ipa: '/ˌkærəˈsɛl/', meaning: 'Băng chuyền nhận hành lý', example: 'Passengers can collect checked bags at carousel number 4.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Tại quầy check-in sân bay, bạn muốn xin ghế ngồi cạnh lối đi thì nói thế nào?',
              options: [
                'Could I have an aisle seat if one is available, please?',
                'Put me on the road chair please.',
                'I want sit outside the window.',
                'Give me the hallway seat.'
              ],
              correctIndex: 0,
              explanation: '"Aisle seat" (/aɪl siːt/ - chữ s câm) là ghế cạnh lối đi; "Window seat" là ghế cạnh cửa sổ.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ phù hợp khi trả lời nhân viên Hải quan nhập cảnh:',
              sentence: 'I am visiting Singapore for a four-day technology _____ and sightseeing.',
              correctAnswer: 'conference',
              wordBank: ['conference', 'luggage', 'passport', 'terminal'],
              explanation: '"For a technology conference" (tham dự hội nghị công nghệ) giải thích rõ mục đích chuyến đi.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu hỏi giờ lên máy bay:',
              vietnameseMeaning: 'Chuyến bay của chúng ta đã bắt đầu lên máy bay ở cổng 14 chưa?',
              shuffledTokens: ['at gate 14', 'started boarding', 'Has our', 'flight', 'yet?'],
              correctOrder: ['Has our', 'flight', 'started boarding', 'at gate 14', 'yet?'],
              explanation: '"Start boarding" là bắt đầu cho hành khách lên máy bay.'
            },
            {
              type: 'listening',
              prompt: 'Nghe thông báo tại cổng an ninh sân bay:',
              audioText: 'Please have your boarding pass and passport ready.',
              ipaHint: '/pliːz hæv jɔː ˈbɔːdɪŋ pɑːs ænd ˈpɑːspɔːt ˈrɛdi/',
              explanation: '"Have [something] ready" nghĩa là chuẩn bị sẵn trên tay để xuất trình.'
            },
            {
              type: 'speaking',
              prompt: 'Đọc câu báo thất lạc hành lý ký gửi:',
              targetSentence: 'My checked baggage did not arrive on the carousel.',
              ipaTranscription: '/maɪ tʃɛkt ˈbæɡɪdʒ dɪd nɒt əˈraɪv ɒn ðə ˌkærəˈsɛl/',
              vietnameseTranslation: 'Hành lý ký gửi của tôi không thấy xuất hiện trên băng chuyền.',
              explanation: '"Checked baggage" là hành lý ký gửi, "carry-on luggage" là hành lý xách tay.'
            }
          ]
        },
        {
          id: 'lesson_2_2',
          title: 'Hotel Reservation & Troubleshooting',
          subtitle: 'Nhận phòng, yêu cầu trả phòng muộn & xử lý sự cố',
          xpReward: 35,
          grammarNote: 'Sử dụng "I have a reservation under the name..." khi làm thủ tục nhận phòng (Check-in) tại quầy lễ tân.',
          keyVocab: [
            { word: 'Reservation', ipa: '/ˌrɛzəˈveɪʃən/', meaning: 'Đặt chỗ / Đặt phòng trước', example: 'I have a reservation under the name Nguyen.' },
            { word: 'Complimentary', ipa: '/ˌkɒmplɪˈmɛntəri/', meaning: 'Miễn phí đi kèm dịch vụ', example: 'Is breakfast complimentary with our room?' },
            { word: 'Late checkout', ipa: '/leɪt ˈtʃɛkaʊt/', meaning: 'Trả phòng muộn hơn giờ quy định', example: 'Would it be possible to request a late checkout at 2 PM?' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Khi đến quầy lễ tân khách sạn để nhận phòng đã đặt trước, bạn nói câu nào?',
              options: [
                'Hello, I would like to check in. I have a reservation under the name Minh Anh.',
                'Hello, give me one bed room tonight.',
                'I am booking a hotel yesterday name Minh Anh.',
                'Open the room door for me please.'
              ],
              correctIndex: 0,
              explanation: '"I have a reservation under the name [Tên]" là câu chuẩn xác nhất khi check-in khách sạn.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ có nghĩa là "miễn phí đi kèm dịch vụ phòng":',
              sentence: 'Our hotel offers a _____ buffet breakfast from 6:30 to 10:00 AM.',
              correctAnswer: 'complimentary',
              wordBank: ['complimentary', 'expensive', 'temporary', 'mandatory'],
              explanation: '"Complimentary" trong ngành dịch vụ khách sạn/hàng không có nghĩa là miễn phí tặng kèm.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu xin trả phòng muộn:',
              vietnameseMeaning: 'Tôi có thể xin trả phòng muộn vào lúc 1 giờ chiều được không?',
              shuffledTokens: ['a late checkout', 'request', 'Could I', 'at 1 PM?'],
              correctOrder: ['Could I', 'request', 'a late checkout', 'at 1 PM?'],
              explanation: '"Request a late checkout" là yêu cầu trả phòng muộn.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu báo hỏng điều hòa trong phòng:',
              audioText: 'The air conditioning in my room is not working properly.',
              ipaHint: '/ði eə kənˈdɪʃənɪŋ ɪn maɪ ruːm ɪz nɒt ˈwɜːkɪŋ ˈprɒpəli/',
              explanation: '"Not working properly" nghĩa là hoạt động không bình thường / bị trục trặc.'
            },
            {
              type: 'speaking',
              prompt: 'Đọc câu nhờ lễ tân giữ giúp hành lý sau khi trả phòng:',
              targetSentence: 'Could we leave our luggage at the front desk until evening?',
              ipaTranscription: '/kʊd wiː liːv ˈaʊə ˈlʌɡɪdʒ æt ðə frʌnt dɛsk ənˈtɪl ˈiːvnɪŋ/',
              vietnameseTranslation: 'Chúng tôi có thể gửi hành lý ở quầy lễ tân đến buổi tối được không?',
              explanation: '"Front desk" hoặc "Concierge" là quầy lễ tân / hỗ trợ khách hàng tại khách sạn.'
            }
          ]
        }
      ]
    },
    {
      id: 'unit_3',
      unitNumber: 3,
      cefrLevel: 'B1',
      title: 'Tiếng Anh Công sở & Họp nhóm Quốc tế',
      description: 'Báo cáo tiến độ Daily Standup, thảo luận kỹ thuật, phản biện lịch sự và viết Email.',
      lessons: [
        {
          id: 'lesson_3_1',
          title: 'Daily Standup & Project Update',
          subtitle: 'Cập nhật công việc đang làm, nêu khó khăn (Blocker) & xin hỗ trợ',
          xpReward: 40,
          grammarNote: 'Trong buổi họp Daily Standup, cấu trúc chuẩn gồm 3 ý: (1) Hôm qua đã hoàn thành gì (Past Simple), (2) Hôm nay đang làm gì (Present Continuous), (3) Có vướng mắc (Blocker) nào không.',
          keyVocab: [
            { word: 'Blocker', ipa: '/ˈblɒkə/', meaning: 'Trở ngại làm gián đoạn công việc', example: 'We ran into a technical blocker with the payment API.' },
            { word: 'Align on', ipa: '/əˈlaɪn ɒn/', meaning: 'Thống nhất với nhau về mục tiêu/ưu tiên', example: 'Let us align on the top priorities for this sprint.' },
            { word: 'Bottleneck', ipa: '/ˈbɒtlnɛk/', meaning: 'Điểm nghẽn cổ chai làm chậm quy trình', example: 'Code review latency has become our main bottleneck.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Chọn cách diễn đạt tự nhiên nhất khi cập nhật tiến độ trong buổi họp Daily Standup:',
              options: [
                'I am currently working on integrating the payment gateway.',
                'I am currently work for integrate the payment gateway.',
                'Yesterday I will finish the payment gateway.',
                'I have been finished the payment gateway tomorrow.'
              ],
              correctIndex: 0,
              explanation: 'Cấu trúc "be currently working on + V-ing/Noun" dùng để mô tả công việc đang triển khai.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ phù hợp vào chỗ trống:',
              sentence: 'We ran into a minor technical _____, but it should be resolved by this afternoon.',
              correctAnswer: 'blocker',
              wordBank: ['blocker', 'deadline', 'agenda', 'milestone'],
              explanation: '"Technical blocker" là thuật ngữ chỉ trở ngại kỹ thuật làm gián đoạn tiến độ dự án.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp các từ sau thành câu xin dời lịch họp:',
              vietnameseMeaning: 'Chúng ta có thể dời lịch họp sang thứ Năm được không?',
              shuffledTokens: ['Thursday?', 'Could', 'the meeting', 'reschedule', 'we', 'to'],
              correctOrder: ['Could', 'we', 'reschedule', 'the meeting', 'to', 'Thursday?'],
              explanation: '"Could we reschedule [something] to [time]?" là mẫu câu lịch sự để xin dời lịch hẹn.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu phát âm và nhập lại chính xác:',
              audioText: 'Let us align on the top priorities for this sprint.',
              ipaHint: '/lɛt ʌs əˈlaɪn ɒn ðə tɒp praɪˈɒrɪtiz fɔː ðɪs sprɪnt/',
              explanation: '"Align on the top priorities" có nghĩa là thống nhất về các ưu tiên quan trọng nhất.'
            },
            {
              type: 'speaking',
              prompt: 'Đọc to câu bày tỏ sự đồng tình trong cuộc họp:',
              targetSentence: 'I completely agree with your perspective on this.',
              ipaTranscription: '/aɪ kəmˈpliːtli əˈɡriː wɪð jɔː pəˈspɛktɪv ɒn ðɪs/',
              vietnameseTranslation: 'Tôi hoàn toàn đồng ý với góc nhìn của bạn về vấn đề này.',
              explanation: 'Chú ý nhấn trọng âm ở "com-PLETE-ly", "a-GREE" và "per-SPEC-tive".'
            }
          ]
        },
        {
          id: 'lesson_3_2',
          title: 'Expressing Opinions & Polite Disagreement',
          subtitle: 'Đưa ra đề xuất, phản biện khéo léo & giữ không khí xây dựng',
          xpReward: 40,
          grammarNote: 'Khi không đồng ý trong môi trường quốc tế, tránh nói thẳng "You are wrong". Hãy ghi nhận ý kiến trước rồi chuyển hướng: "I see your point, however, have we considered...?"',
          keyVocab: [
            { word: 'Perspective', ipa: '/pəˈspɛktɪv/', meaning: 'Góc nhìn, quan điểm', example: 'From an engineering perspective, this approach is safer.' },
            { word: 'Elaborate', ipa: '/ɪˈlæbəreɪt/', meaning: 'Giải thích chi tiết, mở rộng thêm', example: 'Could you elaborate on how this impacts our timeline?' },
            { word: 'Feasible', ipa: '/ˈfiːzəbl/', meaning: 'Khả thi, có thể thực hiện được', example: 'Is it feasible to deliver the prototype by Friday?' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Cách phản biện nào vừa lịch sự vừa chuyên nghiệp nhất trong cuộc họp?',
              options: [
                'I see your point, but from a technical perspective, we might need more time for testing.',
                'That idea is bad and impossible to code.',
                'You do not understand how software works.',
                'No, we will never do that.'
              ],
              correctIndex: 0,
              explanation: '"I see your point, but from a [X] perspective..." giúp phản biện mang tính xây dựng.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền động từ có nghĩa là "giải thích chi tiết hơn":',
              sentence: 'That sounds promising! Could you _____ a bit more on the budget estimate?',
              correctAnswer: 'elaborate',
              wordBank: ['elaborate', 'hesitate', 'celebrate', 'eliminate'],
              explanation: '"Elaborate on something" (/ɪˈlæbəreɪt/) là trình bày hoặc giải thích kỹ hơn về điều gì.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu hỏi về tính khả thi của kế hoạch:',
              vietnameseMeaning: 'Việc ra mắt tính năng này vào tháng tới có khả thi không?',
              shuffledTokens: ['next month?', 'to launch', 'this feature', 'Is it', 'feasible'],
              correctOrder: ['Is it', 'feasible', 'to launch', 'this feature', 'next month?'],
              explanation: '"Is it feasible to + V?" dùng để hỏi xem một kế hoạch có khả thi hay không.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu đề xuất giải pháp thay thế:',
              audioText: 'What if we focus on the core features first?',
              ipaHint: '/wɒt ɪf wiː ˈfəʊkəs ɒn ðə kɔː ˈfiːtʃəz fɜːst/',
              explanation: '"What if we + V...?" là cách đưa ra gợi ý nhẹ nhàng, khuyến khích thảo luận.'
            },
            {
              type: 'speaking',
              prompt: 'Đọc câu tổng kết các đầu việc cần làm sau cuộc họp:',
              targetSentence: 'Let us summarize the key action items before we wrap up.',
              ipaTranscription: '/lɛt ʌs ˈsʌməraɪz ðə kiː ˈækʃən ˈaɪtəmz bɪˈfɔː wiː ræp ʌp/',
              vietnameseTranslation: 'Hãy tóm tắt lại các đầu việc chính trước khi chúng ta kết thúc cuộc họp nhé.',
              explanation: '"Action items" là các đầu việc cần thực hiện; "wrap up" là kết thúc/khép lại buổi họp.'
            }
          ]
        }
      ]
    },
    {
      id: 'unit_4',
      unitNumber: 4,
      cefrLevel: 'B1-B2',
      title: 'Phỏng vấn Quốc tế & Phát triển Sự nghiệp',
      description: 'Giới thiệu bản thân ấn tượng, trả lời câu hỏi tình huống STAR và đàm phán lương.',
      lessons: [
        {
          id: 'lesson_4_1',
          title: 'Behavioral Interview (STAR Method)',
          subtitle: 'Trả lời câu hỏi tình huống bằng cấu trúc Situation - Task - Action - Result',
          xpReward: 45,
          grammarNote: 'Khi kể về dự án đã làm trong buổi phỏng vấn, dùng Quá khứ đơn (Past Simple) cho hành động đã thực hiện và nhấn mạnh Kết quả định lượng được (ví dụ: reduced latency by 40%).',
          keyVocab: [
            { word: 'Spearhead', ipa: '/ˈspɪəhɛd/', meaning: 'Dẫn dắt, đi đầu một sáng kiến/dự án', example: 'I spearheaded the migration to Flutter Clean Architecture.' },
            { word: 'Collaborate', ipa: '/kəˈlæbəreɪt/', meaning: 'Phối hợp chặt chẽ cùng nhau', example: 'I collaborated with cross-functional teams to ship on time.' },
            { word: 'Measurable', ipa: '/ˈmɛʒərəbl/', meaning: 'Có thể đo lường được bằng số liệu', example: 'The optimization delivered a measurable boost in retention.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Khi nhà tuyển dụng hỏi về thành tựu nổi bật nhất, câu trả lời nào thuyết phục nhất theo chuẩn STAR?',
              options: [
                'I redesigned our caching layer, which reduced API response time by 45% for 200,000 daily users.',
                'I worked very hard every day and my boss liked me.',
                'I know how to write code in many languages.',
                'My team did a project last year and it was okay.'
              ],
              correctIndex: 0,
              explanation: 'Câu trả lời xuất sắc nêu rõ Hành động cụ thể (redesigned caching layer) và Kết quả định lượng (reduced response time by 45%).'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ chỉ sự phối hợp liên phòng ban:',
              sentence: 'I closely _____ with product managers and QA engineers throughout the release cycle.',
              correctAnswer: 'collaborated',
              wordBank: ['collaborated', 'competed', 'complained', 'hesitated'],
              explanation: '"Collaborate with..." (phối hợp với...) thể hiện kỹ năng Teamwork xuất sắc.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu đàm phán mức lương kỳ vọng:',
              vietnameseMeaning: 'Dựa trên kinh nghiệm của mình, tôi kỳ vọng mức thu nhập cạnh tranh.',
              shuffledTokens: ['a competitive', 'Based on', 'my experience,', 'I am looking for', 'compensation package.'],
              correctOrder: ['Based on', 'my experience,', 'I am looking for', 'a competitive', 'compensation package.'],
              explanation: '"Compensation package" bao gồm lương cứng, thưởng và các phúc lợi đi kèm.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu hỏi phỏng vấn về cách giải quyết xung đột:',
              audioText: 'How do you handle tight deadlines under high pressure?',
              ipaHint: '/haʊ duː juː ˈhændl taɪt ˈdɛdlaɪnz ˈʌndə haɪ ˈprɛʃə/',
              explanation: '"Handle tight deadlines under high pressure" là xử lý hạn chót gấp gáp dưới áp lực cao.'
            },
            {
              type: 'speaking',
              prompt: 'Luyện nói câu giới thiệu thế mạnh bản thân:',
              targetSentence: 'My core strength is building scalable and user-friendly applications.',
              ipaTranscription: '/maɪ kɔː strɛŋθ ɪz ˈbɪldɪŋ ˈskeɪləbl ænd ˈjuːzə ˈfrɛndli ˌæplɪˈkeɪʃənz/',
              vietnameseTranslation: 'Thế mạnh cốt lõi của tôi là xây dựng các ứng dụng có khả năng mở rộng và thân thiện với người dùng.',
              explanation: '"Core strength" là điểm mạnh cốt lõi; "scalable" là có khả năng mở rộng quy mô lớn.'
            }
          ]
        }
      ]
    },
    {
      id: 'unit_5',
      unitNumber: 5,
      cefrLevel: 'B2',
      title: 'Thuyết trình Chiến lược & Quản trị Rủi ro',
      description: 'Trình bày lộ trình sản phẩm, thuyết phục lãnh đạo và kiểm soát rủi ro dự án.',
      lessons: [
        {
          id: 'lesson_5_1',
          title: 'Pitching Roadmap & Mitigating Risks',
          subtitle: 'Trình bày cột mốc (Milestones) & phương án giảm thiểu rủi ro',
          xpReward: 50,
          grammarNote: 'Sử dụng động từ "mitigate" (giảm thiểu rủi ro) và danh từ "contingency plan" (kế hoạch dự phòng) để tăng sức nặng chuyên môn.',
          keyVocab: [
            { word: 'Mitigate', ipa: '/ˈmɪtɪɡeɪt/', meaning: 'Giảm thiểu rủi ro hoặc tác động tiêu cực', example: 'Automated tests help mitigate regression risks.' },
            { word: 'Milestone', ipa: '/ˈmaɪlstəʊn/', meaning: 'Cột mốc quan trọng của dự án', example: 'We are on track to hit our Q4 milestone.' },
            { word: 'Contingency plan', ipa: '/kənˈtɪndʒənsi plæn/', meaning: 'Phương án dự phòng khi có sự cố', example: 'We prepared a contingency plan in case the server overloads.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Trong buổi thuyết trình với Ban giám đốc, câu nào thể hiện tư duy quản trị rủi ro tốt nhất?',
              options: [
                'To mitigate potential delays, we have prepared a fallback contingency plan.',
                'Nothing bad will ever happen to our project, trust me.',
                'If the server crashes, we will just wait and see.',
                'We do not need any testing before release.'
              ],
              correctIndex: 0,
              explanation: '"To mitigate potential delays..." kết hợp "contingency plan" thể hiện sự chuẩn bị kỹ lưỡng.'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền từ chỉ cột mốc quan trọng của dự án:',
              sentence: 'Launching the offline learning mode is our biggest _____ this quarter.',
              correctAnswer: 'milestone',
              wordBank: ['milestone', 'obstacle', 'accident', 'souvenir'],
              explanation: '"Milestone" là cột mốc đánh dấu bước tiến lớn trong lộ trình dự án.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu trình bày lợi tức đầu tư (ROI):',
              vietnameseMeaning: 'Sáng kiến này sẽ mang lại giá trị lâu dài đáng kể cho người dùng.',
              shuffledTokens: ['long-term value', 'will deliver', 'substantial', 'This initiative', 'to our users.'],
              correctOrder: ['This initiative', 'will deliver', 'substantial', 'long-term value', 'to our users.'],
              explanation: '"Deliver substantial long-term value" là mang lại giá trị lâu dài đáng kể.'
            },
            {
              type: 'listening',
              prompt: 'Nghe câu nhận xét về tiến độ dự án:',
              audioText: 'We are currently on track to meet all quarterly objectives.',
              ipaHint: '/wiː ɑː ˈkʌrəntli ɒn træk tuː miːt ɔːl ˈkwɔːtəli əbˈdʒɛktɪvz/',
              explanation: '"Be on track" nghĩa là đang đi đúng tiến độ kế hoạch.'
            },
            {
              type: 'speaking',
              prompt: 'Luyện phát âm câu đề xuất phân bổ nguồn lực:',
              targetSentence: 'We should allocate more engineering resources to high-impact features.',
              ipaTranscription: '/wiː ʃʊd ˈæləkeɪt mɔːr ˌɛndʒɪˈnɪərɪŋ rɪˈzɔːsɪz tuː haɪ ˈɪmpækt ˈfiːtʃəz/',
              vietnameseTranslation: 'Chúng ta nên phân bổ thêm nguồn lực kỹ thuật cho các tính năng có tác động cao.',
              explanation: '"Allocate resources" (/ˈæləkeɪt/) là phân bổ nguồn lực/ngân sách.'
            }
          ]
        }
      ]
    },
    {
      id: 'unit_6',
      unitNumber: 6,
      cefrLevel: 'B2-C1',
      title: 'Học thuật, IELTS & Idioms Bản xứ',
      description: 'Nâng tầm từ vựng học thuật C1, lập luận sắc bén và thành ngữ giao tiếp tự nhiên.',
      lessons: [
        {
          id: 'lesson_6_1',
          title: 'Native Idioms & IELTS Academic Fluency',
          subtitle: 'Sử dụng thành ngữ tinh tế & cấu trúc lập luận điểm 8.0+ IELTS',
          xpReward: 55,
          grammarNote: 'Trong IELTS Speaking Part 3 và giao tiếp cấp cao, thay thế "very big change" bằng "a paradigm shift" hoặc "a substantial transformation".',
          keyVocab: [
            { word: 'On the same page', ipa: '/ɒn ðə seɪm peɪdʒ/', meaning: 'Thống nhất, hiểu đúng ý nhau', example: 'Let us review the spec so everyone is on the same page.' },
            { word: 'Touch base', ipa: '/tʌtʃ beɪs/', meaning: 'Liên hệ nhanh để cập nhật thông tin', example: 'I will touch base with the design team tomorrow morning.' },
            { word: 'Ubiquitous', ipa: '/juːˈbɪkwɪtəs/', meaning: 'Phổ biến ở khắp mọi nơi (Từ vựng C1)', example: 'Artificial intelligence has become ubiquitous in modern education.' }
          ],
          questions: [
            {
              type: 'multiple_choice',
              prompt: 'Từ vựng C1 nào có nghĩa là "hiện diện ở khắp mọi nơi, cực kỳ phổ biến"?',
              options: [
                'Ubiquitous',
                'Scarce',
                'Negligible',
                'Obsolete'
              ],
              correctIndex: 0,
              explanation: '"Ubiquitous" (/juːˈbɪkwɪtəs/) nghĩa là có mặt ở khắp nơi; trái nghĩa với "scarce" (khan hiếm) và "obsolete" (lỗi thời).'
            },
            {
              type: 'fill_blank',
              prompt: 'Điền thành ngữ mang nghĩa "nhìn vào bức tranh tổng thể thay vì tiểu tiết":',
              sentence: 'Instead of arguing over minor UI colors, we need to focus on the big _____.',
              correctAnswer: 'picture',
              wordBank: ['picture', 'photo', 'painting', 'mirror'],
              explanation: 'Idiom "Look at / focus on the big picture" nghĩa là tập trung vào bức tranh toàn cảnh/mục tiêu lớn.'
            },
            {
              type: 'sentence_order',
              prompt: 'Sắp xếp câu lập luận học thuật IELTS:',
              vietnameseMeaning: 'Trí tuệ nhân tạo đóng vai trò then chốt trong việc cá nhân hóa giáo dục.',
              shuffledTokens: ['in personalizing', 'plays a pivotal role', 'Artificial intelligence', 'modern education.'],
              correctOrder: ['Artificial intelligence', 'plays a pivotal role', 'in personalizing', 'modern education.'],
              explanation: '"Play a pivotal role in + V-ing/Noun" (đóng vai trò then chốt trong...) là cụm từ ăn điểm cao trong IELTS.'
            },
            {
              type: 'listening',
              prompt: 'Nghe và viết lại câu thành ngữ công sở:',
              audioText: 'Let us touch base tomorrow to make sure we are on the same page.',
              ipaHint: '/lɛt ʌs tʌtʃ beɪs təˈmɒrəʊ tuː meɪk ʃʊə wiː ɑːr ɒn ðə seɪm peɪdʒ/',
              explanation: 'Kết hợp 2 idioms cực kỳ phổ biến: "touch base" (liên hệ cập nhật) và "on the same page" (hiểu thống nhất).'
            },
            {
              type: 'speaking',
              prompt: 'Luyện phát âm câu học thuật C1:',
              targetSentence: 'Lifelong learning is indispensable in a rapidly evolving digital economy.',
              ipaTranscription: '/ˈlaɪflɒŋ ˈlɜːnɪŋ ɪz ˌɪndɪˈspɛnsəbl ɪn ə ˈræpɪdli ɪˈvɒlvɪŋ ˈdɪdʒɪtl ɪˈkɒnəmi/',
              vietnameseTranslation: 'Học tập suốt đời là điều không thể thiếu trong một nền kinh tế số biến đổi nhanh chóng.',
              explanation: '"Indispensable" (/ˌɪndɪˈspɛnsəbl/) là không thể thiếu được (từ vựng C1 thay cho "very important").'
            }
          ]
        }
      ]
    }
  ],

  srsFlashcards: [
    {
      id: 'srs_1',
      word: 'Resilient',
      ipa: '/rɪˈzɪliənt/',
      cefr: 'B2',
      partOfSpeech: 'Adjective • B2',
      topic: 'Công nghệ & IT',
      vietnameseMeaning: 'Kiên cường, có khả năng phục hồi nhanh sau sự cố',
      exampleSentence: 'Our engineering team built a resilient offline-first architecture.',
      grammarNote: 'Tính từ đứng trước danh từ (a resilient system) hoặc sau động từ nối to be/remain (remain resilient to/against something).',
      usageTip: 'Dùng rất phổ biến trong cả Công nghệ (hệ thống chịu lỗi tốt) và Đời sống/Kinh doanh (con người/doanh nghiệp vượt qua khủng hoảng).',
      collocations: ['resilient architecture', 'highly resilient to change', 'build a resilient team'],
      wordFamily: 'Resilient (adj) • Resilience (n) • Resiliently (adv)',
      synonyms: ['Robust', 'Tough', 'Adaptable'],
      antonyms: ['Fragile', 'Vulnerable'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_2',
      word: 'Negotiate',
      ipa: '/nɪˈɡəʊʃieɪt/',
      cefr: 'B1',
      partOfSpeech: 'Verb • B1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Đàm phán, thương lượng',
      exampleSentence: 'We managed to negotiate a more flexible delivery timeline.',
      grammarNote: 'Cấu trúc chuẩn: negotiate [something] WITH [somebody] (đàm phán cái gì với ai). Lưu ý không dùng "negotiate to somebody".',
      usageTip: 'Dùng trong phỏng vấn lương (negotiate a salary package), hợp đồng thương mại hoặc thương lượng thời hạn dự án.',
      collocations: ['negotiate a contract', 'negotiate a better deal', 'negotiating table'],
      wordFamily: 'Negotiate (v) • Negotiation (n) • Negotiator (n) • Negotiable (adj)',
      synonyms: ['Bargain', 'Discuss terms'],
      antonyms: ['Demand', 'Refuse'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_3',
      word: 'Elaborate',
      ipa: '/ɪˈlæbəreɪt/',
      cefr: 'B2',
      partOfSpeech: 'Verb • B2',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Giải thích chi tiết hơn, trình bày kỹ hơn',
      exampleSentence: 'Could you elaborate on your proposal for the mobile app redesign?',
      grammarNote: 'Nội động từ luôn đi kèm giới từ ON/UPON: "elaborate ON something" (giải thích chi tiết hơn về vấn đề gì).',
      usageTip: 'Câu cửa miệng cực kỳ lịch sự trong các buổi họp quốc tế hoặc phỏng vấn khi bạn muốn đối phương nói rõ hơn.',
      collocations: ['elaborate on a point', 'care to elaborate', 'elaborate further'],
      wordFamily: 'Elaborate (v / adj) • Elaboration (n) • Elaborately (adv)',
      synonyms: ['Expand on', 'Explain in detail', 'Clarify'],
      antonyms: ['Summarize', 'Simplify'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_4',
      word: 'Itinerary',
      ipa: '/aɪˈtɪnərəri/',
      cefr: 'B1',
      partOfSpeech: 'Noun • B1',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Lịch trình chi tiết của chuyến đi',
      exampleSentence: 'I will send the business trip itinerary to everyone by noon.',
      grammarNote: 'Danh từ đếm được (an itinerary / itineraries). Đi với giới từ ON: "be on the itinerary".',
      usageTip: 'Thường xuyên xuất hiện tại quầy hải quan sân bay, đặt vé máy bay, công tác nước ngoài hoặc bài nghe TOEIC/IELTS.',
      collocations: ['travel itinerary', 'detailed itinerary', 'plan an itinerary'],
      wordFamily: 'Itinerary (n) • Itinerant (adj)',
      synonyms: ['Schedule', 'Travel plan', 'Route'],
      antonyms: ['Improvisation'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_5',
      word: 'Feasible',
      ipa: '/ˈfiːzəbl/',
      cefr: 'B2',
      partOfSpeech: 'Adjective • B2',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Khả thi, có thể thực hiện được',
      exampleSentence: 'Deploying the AI feature this week is completely feasible.',
      grammarNote: 'Cấu trúc: "It is feasible (for somebody) to do something" hoặc "a feasible solution/plan".',
      usageTip: 'Chuyên nghiệp hơn nhiều so với "possible" hoặc "can do" khi đánh giá tính khả thi về kỹ thuật và ngân sách.',
      collocations: ['technically feasible', 'economically feasible', 'feasible alternative'],
      wordFamily: 'Feasible (adj) • Feasibility (n) • Feasibly (adv)',
      synonyms: ['Viable', 'Achievable', 'Practical'],
      antonyms: ['Impractical', 'Unfeasible', 'Impossible'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_6',
      word: 'Prioritize',
      ipa: '/praɪˈɒrətaɪz/',
      cefr: 'B1',
      partOfSpeech: 'Verb • B1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Ưu tiên giải quyết việc quan trọng trước',
      exampleSentence: 'We need to prioritize core stability before adding new animations.',
      grammarNote: 'Ngoại động từ: "prioritize + Noun / V-ing" hoặc "prioritize A over B" (ưu tiên A hơn B).',
      usageTip: 'Từ khóa vàng khi trả lời phỏng vấn về quản lý thời gian (Time Management) hoặc họp lập kế hoạch Sprint.',
      collocations: ['prioritize tasks', 'strictly prioritize', 'prioritize quality over speed'],
      wordFamily: 'Prioritize (v) • Priority (n) • Prioritization (n)',
      synonyms: ['Rank first', 'Focus on'],
      antonyms: ['Neglect', 'Postpone'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_7',
      word: 'Bottleneck',
      ipa: '/ˈbɒtlnɛk/',
      cefr: 'B2',
      partOfSpeech: 'Noun • B2',
      topic: 'Công nghệ & IT',
      vietnameseMeaning: 'Điểm nghẽn cổ chai làm chậm toàn bộ hệ thống',
      exampleSentence: 'Database latency was the primary bottleneck during peak traffic.',
      grammarNote: 'Danh từ đếm được: "a bottleneck IN [a system/process]". Động từ đi kèm: identify / eliminate / resolve a bottleneck.',
      usageTip: 'Dùng để chỉ khâu yếu nhất/chậm nhất làm đình trệ cả quy trình làm việc hoặc hiệu năng phần mềm.',
      collocations: ['performance bottleneck', 'eliminate a bottleneck', 'major bottleneck'],
      wordFamily: 'Bottleneck (n / v)',
      synonyms: ['Obstacle', 'Blockage', 'Constraint'],
      antonyms: ['Accelerator', 'Catalyst'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_8',
      word: 'Complimentary',
      ipa: '/ˌkɒmplɪˈmɛntəri/',
      cefr: 'B1',
      partOfSpeech: 'Adjective • B1',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Miễn phí tặng kèm (bữa sáng, đồ uống, nâng hạng)',
      exampleSentence: 'Your hotel booking includes a complimentary buffet breakfast.',
      grammarNote: 'Đứng trước danh từ: "complimentary breakfast / shuttle / Wi-Fi / drink".',
      usageTip: 'Đừng nhầm với "complementary" (với chữ e - mang nghĩa bổ sung cho nhau). Trong khách sạn/máy bay, "complimentary" (chữ i) luôn nghĩa là MIỄN PHÍ!',
      collocations: ['complimentary breakfast', 'complimentary upgrade', 'complimentary ticket'],
      wordFamily: 'Complimentary (adj) • Compliment (n / v)',
      synonyms: ['Free of charge', 'On the house', 'Gratis'],
      antonyms: ['Paid', 'Chargeable'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_9',
      word: 'Aisle',
      ipa: '/aɪl/',
      cefr: 'A2',
      partOfSpeech: 'Noun • A2',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Lối đi giữa các dãy ghế (máy bay, tàu, siêu thị)',
      exampleSentence: 'I always prefer an aisle seat on long-haul international flights.',
      grammarNote: 'Danh từ đếm được: "an aisle seat" (ghế cạnh lối đi), "walk down the aisle".',
      usageTip: 'LƯU Ý PHÁT ÂM: Chữ "s" hoàn toàn CÂM! Phát âm là /aɪl/ (giống hệt từ "I\'ll").',
      collocations: ['aisle seat', 'window or aisle', 'grocery aisle'],
      wordFamily: 'Aisle (n)',
      synonyms: ['Passageway', 'Walkway', 'Corridor'],
      antonyms: ['Window'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_10',
      word: 'Boarding',
      ipa: '/ˈbɔːdɪŋ/',
      cefr: 'A2',
      partOfSpeech: 'Noun • A2',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Việc lên máy bay / tàu thủy',
      exampleSentence: 'Please scan your digital boarding pass at the security gate.',
      grammarNote: 'Danh từ ghép phổ biến: "boarding pass" (thẻ lên máy bay), "boarding gate" (cổng lên máy bay), "boarding time" (giờ lên máy bay).',
      usageTip: 'Khi loa sân bay gọi "Final boarding call", nghĩa là chuyến bay sắp đóng cửa, bạn phải ra cổng ngay lập tức.',
      collocations: ['boarding pass', 'boarding gate', 'priority boarding'],
      wordFamily: 'Board (v / n) • Boarding (n)',
      synonyms: ['Embarkation'],
      antonyms: ['Disembarkation', 'Landing'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_11',
      word: 'Mitigate',
      ipa: '/ˈmɪtɪɡeɪt/',
      cefr: 'C1',
      partOfSpeech: 'Verb • C1',
      topic: 'IELTS & Học thuật',
      vietnameseMeaning: 'Giảm thiểu rủi ro hoặc hậu quả nghiêm trọng',
      exampleSentence: 'Strict quality checks help mitigate production failures.',
      grammarNote: 'Ngoại động từ trang trọng: "mitigate + risk / impact / damage / effect".',
      usageTip: 'Từ vựng C1 cực kỳ ăn điểm trong IELTS Writing Task 2 và báo cáo kỹ thuật/kinh doanh (thay cho "reduce bad effects").',
      collocations: ['mitigate risks', 'mitigate the impact of', 'mitigating factors'],
      wordFamily: 'Mitigate (v) • Mitigation (n)',
      synonyms: ['Alleviate', 'Minimize', 'Reduce'],
      antonyms: ['Aggravate', 'Exacerbate', 'Worsen'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_12',
      word: 'Indispensable',
      ipa: '/ˌɪndɪˈspɛnsəbl/',
      cefr: 'C1',
      partOfSpeech: 'Adjective • C1',
      topic: 'IELTS & Học thuật',
      vietnameseMeaning: 'Không thể thiếu được, tối quan trọng',
      exampleSentence: 'Clear communication is indispensable for remote engineering teams.',
      grammarNote: 'Đi với giới từ TO hoặc FOR: "be indispensable TO/FOR somebody/something".',
      usageTip: 'Dùng để nhấn mạnh một công cụ, kỹ năng hoặc thành viên quan trọng đến mức không thể thiếu (cấp độ C1 của "very important").',
      collocations: ['indispensable tool', 'indispensable part of', 'prove indispensable'],
      wordFamily: 'Indispensable (adj) • Indispensability (n)',
      synonyms: ['Essential', 'Crucial', 'Vital'],
      antonyms: ['Dispensable', 'Superfluous', 'Unnecessary'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_13',
      word: 'Ubiquitous',
      ipa: '/juːˈbɪkwɪtəs/',
      cefr: 'C1',
      partOfSpeech: 'Adjective • C1',
      topic: 'IELTS & Học thuật',
      vietnameseMeaning: 'Hiện diện ở khắp mọi nơi, cực kỳ phổ biến',
      exampleSentence: 'Smartphones have become ubiquitous in modern daily life.',
      grammarNote: 'Tính từ trang trọng: "become ubiquitous IN [place/era]".',
      usageTip: 'Phát âm bắt đầu bằng âm /juː/ (giống chữ "you"), không đọc là /ʌ/. Rất hay dùng khi nói về công nghệ, AI, Internet trong IELTS.',
      collocations: ['become ubiquitous', 'ubiquitous computing', 'ubiquitous presence'],
      wordFamily: 'Ubiquitous (adj) • Ubiquity (n)',
      synonyms: ['Omnipresent', 'Pervasive', 'Everywhere'],
      antonyms: ['Rare', 'Scarce'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_14',
      word: 'Collaborate',
      ipa: '/kəˈlæbəreɪt/',
      cefr: 'B1',
      partOfSpeech: 'Verb • B1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Hợp tác, phối hợp chặt chẽ cùng nhau',
      exampleSentence: 'I collaborated with cross-functional teams to ship the product on time.',
      grammarNote: 'Cấu trúc: "collaborate WITH [somebody] ON [something]" (phối hợp với ai về dự án/công việc gì).',
      usageTip: 'Hay hơn nhiều so với "work with" khi viết CV hoặc trả lời phỏng vấn bằng tiếng Anh.',
      collocations: ['collaborate closely with', 'cross-functional collaboration', 'collaborate on a project'],
      wordFamily: 'Collaborate (v) • Collaboration (n) • Collaborative (adj)',
      synonyms: ['Cooperate', 'Team up', 'Partner'],
      antonyms: ['Work in isolation', 'Compete'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_15',
      word: 'Scalable',
      ipa: '/ˈskeɪləbl/',
      cefr: 'B2',
      partOfSpeech: 'Adjective • B2',
      topic: 'Công nghệ & IT',
      vietnameseMeaning: 'Có khả năng mở rộng quy mô lớn mà vẫn mượt mà',
      exampleSentence: 'We designed a scalable cloud backend to handle millions of requests.',
      grammarNote: 'Tính từ: "highly scalable architecture / business model".',
      usageTip: 'Thuật ngữ cốt lõi trong Kỹ thuật phần mềm (Software Engineering) và Khởi nghiệp (Startup/Business).',
      collocations: ['scalable architecture', 'scalable solution', 'horizontally scalable'],
      wordFamily: 'Scale (v / n) • Scalable (adj) • Scalability (n)',
      synonyms: ['Expandable', 'Flexible'],
      antonyms: ['Rigid', 'Limited'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_16',
      word: 'Spearhead',
      ipa: '/ˈspɪəhɛd/',
      cefr: 'C1',
      partOfSpeech: 'Verb • C1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Dẫn dắt, tiên phong thực hiện một dự án quan trọng',
      exampleSentence: 'She spearheaded the AI transformation initiative across the company.',
      grammarNote: 'Ngoại động từ: "spearhead + a project / campaign / initiative / migration".',
      usageTip: 'Động từ cực mạnh (Action Verb) để đưa vào CV hoặc buổi phỏng vấn vị trí Senior/Lead thay cho "I led...".',
      collocations: ['spearhead an initiative', 'spearhead the development', 'spearhead a campaign'],
      wordFamily: 'Spearhead (v / n)',
      synonyms: ['Lead', 'Champion', 'Pioneer'],
      antonyms: ['Follow'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_17',
      word: 'Receipt',
      ipa: '/rɪˈsiːt/',
      cefr: 'A2',
      partOfSpeech: 'Noun • A2',
      topic: 'Giao tiếp Hàng ngày',
      vietnameseMeaning: 'Biên lai thanh toán (chú ý âm "p" câm)',
      exampleSentence: 'Would you like your receipt printed or sent via email?',
      grammarNote: 'Danh từ đếm được (a receipt). Cụm cố định: "keep the receipt" (giữ biên lai), "upon receipt of" (ngay khi nhận được).',
      usageTip: 'LƯU Ý PHÁT ÂM & NHẦM LẪN: Chữ "p" bị CÂM (/rɪˈsiːt/). Đừng nhầm với "recipe" (/ˈrɛsɪpi/ - công thức nấu ăn)!',
      collocations: ['original receipt', 'digital receipt', 'acknowledge receipt of'],
      wordFamily: 'Receive (v) • Receipt (n) • Receiver (n)',
      synonyms: ['Proof of purchase', 'Sales slip'],
      antonyms: ['Invoice'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_18',
      word: 'Reservation',
      ipa: '/ˌrɛzəˈveɪʃən/',
      cefr: 'A2',
      partOfSpeech: 'Noun • A2',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Sự đặt chỗ / đặt bàn / đặt phòng trước',
      exampleSentence: 'Hello, I have a hotel reservation under the name Minh Anh.',
      grammarNote: 'Đi với động từ MAKE hoặc HAVE: "make a reservation", "have a reservation UNDER the name [Tên]".',
      usageTip: 'Khi check-in khách sạn hoặc nhà hàng, luôn dùng giới từ "UNDER the name..." (đặt dưới tên...).',
      collocations: ['make a reservation', 'reservation under the name', 'confirm a reservation'],
      wordFamily: 'Reserve (v / n) • Reservation (n) • Reserved (adj)',
      synonyms: ['Booking'],
      antonyms: ['Cancellation', 'Walk-in'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_19',
      word: 'Perspective',
      ipa: '/pəˈspɛktɪv/',
      cefr: 'B1',
      partOfSpeech: 'Noun • B1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Góc nhìn, quan điểm',
      exampleSentence: 'From a technical perspective, this offline approach is much faster.',
      grammarNote: 'Cấu trúc cực hay trong họp & viết luận: "From a [technical/business/user] perspective, ...".',
      usageTip: 'Giúp câu nói của bạn khách quan và chuyên nghiệp hơn nhiều so với "I think...".',
      collocations: ['from my perspective', 'broader perspective', 'put things into perspective'],
      wordFamily: 'Perspective (n)',
      synonyms: ['Viewpoint', 'Standpoint', 'Outlook'],
      antonyms: ['Blindness'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_20',
      word: 'Milestone',
      ipa: '/ˈmaɪlstəʊn/',
      cefr: 'B1',
      partOfSpeech: 'Noun • B1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Cột mốc quan trọng của dự án hoặc cuộc đời',
      exampleSentence: 'Reaching 100,000 daily learners is a major milestone for our team.',
      grammarNote: 'Động từ thường đi kèm: "reach / hit / achieve / mark a milestone".',
      usageTip: 'Dùng trong báo cáo tiến độ dự án (Project Roadmap) hoặc thuyết trình với khách hàng.',
      collocations: ['major milestone', 'hit a milestone', 'project milestone'],
      wordFamily: 'Milestone (n)',
      synonyms: ['Landmark', 'Turning point', 'Achievement'],
      antonyms: ['Setback'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_21',
      word: 'Schedule',
      ipa: '/ˈʃɛdjuːl/ • /ˈskɛdʒuːl/',
      cefr: 'A1',
      partOfSpeech: 'Noun / Verb • A1',
      topic: 'Giao tiếp Hàng ngày',
      vietnameseMeaning: 'Lịch trình, thời gian biểu / Sắp xếp lịch',
      exampleSentence: 'Let me check my schedule and get back to you this afternoon.',
      grammarNote: 'Đi với giới từ ON / BEHIND / AHEAD OF: "on schedule" (đúng tiến độ), "behind schedule" (chậm tiến độ), "schedule a meeting FOR Monday".',
      usageTip: 'Anh-Anh đọc là /ˈʃɛdjuːl/, còn Anh-Mỹ đọc là /ˈskɛdʒuːl/ — cả hai cách phát âm đều chuẩn quốc tế!',
      collocations: ['busy schedule', 'ahead of schedule', 'behind schedule'],
      wordFamily: 'Schedule (n / v) • Scheduled (adj) • Reschedule (v)',
      synonyms: ['Timetable', 'Agenda', 'Calendar'],
      antonyms: ['Disorder'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_22',
      word: 'Recommend',
      ipa: '/ˌrɛkəˈmɛnd/',
      cefr: 'A2',
      partOfSpeech: 'Verb • A2',
      topic: 'Giao tiếp Hàng ngày',
      vietnameseMeaning: 'Gợi ý, giới thiệu, khuyên dùng',
      exampleSentence: 'Could you recommend a good local restaurant near the hotel?',
      grammarNote: 'CẤU TRÚC RẤT HAY SAI: Dùng "recommend + V-ing" hoặc "recommend (that) somebody (should) V-inf" (KHÔNG dùng "recommend somebody to do").',
      usageTip: 'Ví dụ đúng: "I recommend trying the signature latte" (không nói "I recommend you to try").',
      collocations: ['highly recommend', 'strongly recommend', 'recommend a dish'],
      wordFamily: 'Recommend (v) • Recommendation (n) • Recommended (adj)',
      synonyms: ['Suggest', 'Endorse', 'Advise'],
      antonyms: ['Discourage', 'Warn against'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_23',
      word: 'Available',
      ipa: '/əˈveɪləbl/',
      cefr: 'A1',
      partOfSpeech: 'Adjective • A1',
      topic: 'Giao tiếp Hàng ngày',
      vietnameseMeaning: 'Có sẵn (hàng hóa/chỗ ngồi) hoặc Rảnh rỗi (con người)',
      exampleSentence: 'Are you available for a quick fifteen-minute call tomorrow morning?',
      grammarNote: 'Dùng cho vật: "available in [size/color]" / "available FOR purchase". Dùng cho người: "available FOR a meeting" (rảnh để họp).',
      usageTip: 'Khi hẹn lịch phỏng vấn hoặc họp, nói "I am available at 2 PM" lịch sự và chuyên nghiệp hơn nhiều so với "I am free".',
      collocations: ['readily available', 'available seat', 'make yourself available'],
      wordFamily: 'Available (adj) • Availability (n) • Unavailable (adj)',
      synonyms: ['Accessible', 'Free', 'In stock'],
      antonyms: ['Unavailable', 'Occupied', 'Out of stock'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_24',
      word: 'Luggage',
      ipa: '/ˈlʌɡɪdʒ/',
      cefr: 'A1',
      partOfSpeech: 'Noun (Uncountable) • A1',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Hành lý mang theo khi đi du lịch',
      exampleSentence: 'Could we leave our luggage at the hotel front desk until 5 PM?',
      grammarNote: 'LƯU Ý NGỮ PHÁP: "Luggage" và "Baggage" là DANH TỪ KHÔNG ĐẾM ĐƯỢC! Không bao giờ thêm "s" (luggages) hay dùng "a luggage" — hãy dùng "a piece of luggage".',
      usageTip: 'Muốn đếm số kiện vali, hãy nói "two pieces of luggage" hoặc "two suitcases".',
      collocations: ['carry-on luggage', 'checked luggage', 'lost luggage'],
      wordFamily: 'Luggage (n)',
      synonyms: ['Baggage', 'Suitcases'],
      antonyms: [],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_25',
      word: 'Deadline',
      ipa: '/ˈdɛdlaɪn/',
      cefr: 'A2',
      partOfSpeech: 'Noun • A2',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Hạn chót phải hoàn thành công việc',
      exampleSentence: 'We worked closely together to meet the tight project deadline.',
      grammarNote: 'Các động từ chuẩn đi kèm: "meet a deadline" (kịp hạn), "miss a deadline" (trễ hạn), "extend a deadline" (gia hạn), "set a deadline FOR...".',
      usageTip: '"Tight deadline" là hạn chót rất gấp gáp.',
      collocations: ['tight deadline', 'meet the deadline', 'strict deadline'],
      wordFamily: 'Deadline (n)',
      synonyms: ['Due date', 'Time limit', 'Cutoff'],
      antonyms: ['Extension'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_26',
      word: 'Refund',
      ipa: '/ˈriːfʌnd/',
      cefr: 'A2',
      partOfSpeech: 'Noun / Verb • A2',
      topic: 'Giao tiếp Hàng ngày',
      vietnameseMeaning: 'Khoản tiền hoàn trả lại / Hoàn tiền',
      exampleSentence: 'Customers can request a full refund within fourteen days of purchase.',
      grammarNote: 'Danh từ đọc nhấn âm đầu /ˈriːfʌnd/ ("get/issue a full refund"); Động từ nhấn âm hai /rɪˈfʌnd/.',
      usageTip: 'Khi mua hàng bị lỗi hoặc hủy vé máy bay/khách sạn, cụm "eligible for a full refund" nghĩa là đủ điều kiện hoàn tiền 100%.',
      collocations: ['full refund', 'partial refund', 'request a refund'],
      wordFamily: 'Refund (n / v) • Refundable (adj) • Non-refundable (adj)',
      synonyms: ['Reimbursement', 'Repayment'],
      antonyms: ['Charge', 'Payment'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_27',
      word: 'Accommodate',
      ipa: '/əˈkɒmədeɪt/',
      cefr: 'B2',
      partOfSpeech: 'Verb • B2',
      topic: 'Du lịch & Sân bay',
      vietnameseMeaning: 'Đáp ứng yêu cầu / Cung cấp đủ chỗ cho ai đó',
      exampleSentence: 'The conference hall can accommodate up to five hundred guests.',
      grammarNote: 'Ngoại động từ: "accommodate + somebody / a request / dietary needs". LƯU Ý CHÍNH TẢ: Có 2 chữ "c" và 2 chữ "m" (ac-com-mo-date)!',
      usageTip: 'Một trong những từ hay bị viết sai chính tả nhất trong bài thi IELTS Listening & Writing do thiếu chữ "c" hoặc "m".',
      collocations: ['accommodate a request', 'accommodate guests', 'happy to accommodate'],
      wordFamily: 'Accommodate (v) • Accommodation (n) • Accommodating (adj)',
      synonyms: ['Fulfill', 'House', 'Adapt to'],
      antonyms: ['Reject', 'Turn away'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_28',
      word: 'Substantial',
      ipa: '/səbˈstænʃl/',
      cefr: 'C1',
      partOfSpeech: 'Adjective • C1',
      topic: 'IELTS & Học thuật',
      vietnameseMeaning: 'Đáng kể, lớn lao, có giá trị thực chất',
      exampleSentence: 'Regular active recall practice leads to substantial progress in vocabulary.',
      grammarNote: 'Đứng trước danh từ chỉ sự thay đổi, số lượng hoặc giá trị: "substantial improvement / increase / amount / evidence".',
      usageTip: 'Từ vựng vàng trong IELTS Writing Task 1 (mô tả biểu đồ tăng mạnh: a substantial rise) và thuyết trình kinh doanh.',
      collocations: ['substantial amount', 'substantial improvement', 'substantial evidence'],
      wordFamily: 'Substance (n) • Substantial (adj) • Substantially (adv)',
      synonyms: ['Significant', 'Considerable', 'Sizable'],
      antonyms: ['Negligible', 'Minor', 'Trivial'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_29',
      word: 'Contingency',
      ipa: '/kənˈtɪndʒənsi/',
      cefr: 'C1',
      partOfSpeech: 'Noun • C1',
      topic: 'Công sở & Sự nghiệp',
      vietnameseMeaning: 'Tình huống bất ngờ / Phương án dự phòng rủi ro',
      exampleSentence: 'Every critical software release needs a clear contingency plan.',
      grammarNote: 'Thường đi thành cụm danh từ ghép: "contingency plan" (kế hoạch dự phòng), "contingency fund" (quỹ dự phòng), "plan FOR contingencies".',
      usageTip: 'Dùng trong quản lý dự án và tài chính để thể hiện sự chuẩn bị chuyên nghiệp trước mọi kịch bản xấu.',
      collocations: ['contingency plan', 'contingency budget', 'prepare for contingencies'],
      wordFamily: 'Contingency (n) • Contingent (adj)',
      synonyms: ['Backup plan', 'Emergency measure', 'Fallback'],
      antonyms: ['Certainty'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    },
    {
      id: 'srs_30',
      word: 'Pivotal',
      ipa: '/ˈpɪvətl/',
      cefr: 'C1',
      partOfSpeech: 'Adjective • C1',
      topic: 'IELTS & Học thuật',
      vietnameseMeaning: 'Then chốt, mang tính bước ngoặt quyết định',
      exampleSentence: 'Daily consistency plays a pivotal role in mastering a foreign language.',
      grammarNote: 'Cụm cố định kinh điển: "play a pivotal role IN + V-ing / Noun" hoặc "a pivotal moment".',
      usageTip: 'Thay thế hoàn hảo cho "very important role" trong các bài luận IELTS Writing Band 7.5 - 8.5.',
      collocations: ['play a pivotal role', 'pivotal moment', 'pivotal figure'],
      wordFamily: 'Pivot (n / v) • Pivotal (adj)',
      synonyms: ['Crucial', 'Decisive', 'Central'],
      antonyms: ['Peripheral', 'Insignificant'],
      repetition: 0,
      easeFactor: 2.5,
      intervalDays: 0
    }
  ],

  aiScenarios: [
    {
      id: 'sc_interview',
      title: 'Phỏng vấn Kỹ sư Phần mềm Quốc tế',
      roleDescription: 'AI đóng vai Tech Lead tại Silicon Valley phỏng vấn bạn.',
      cefr: 'B1-B2',
      targetVocabulary: ['scalable', 'architecture', 'collaborate', 'bottleneck', 'deadline'],
      initialGreeting: 'Hi there! Welcome to the interview. Could you tell me about a challenging technical project you worked on recently?',
      initialTranslation: 'Xin chào! Chào mừng bạn đến buổi phỏng vấn. Bạn có thể chia sẻ về một dự án kỹ thuật thử thách mà bạn mới thực hiện gần đây không?',
      turns: [
        {
          reply: 'That sounds like a great project! What was the biggest technical bottleneck you faced, and how did your architecture solve it?',
          translation: 'Dự án nghe rất thú vị! Điểm nghẽn kỹ thuật lớn nhất bạn gặp phải là gì và kiến trúc của bạn đã giải quyết nó thế nào?',
          suggestions: [
            'Our main bottleneck was slow API loading, so we designed a scalable offline cache.',
            'We used Clean Architecture so the team could collaborate on features independently.'
          ]
        },
        {
          reply: 'Impressive approach! How did you collaborate with product managers and QA when facing a tight deadline?',
          translation: 'Cách tiếp cận rất ấn tượng! Bạn đã phối hợp với PM và QA như thế nào khi đối mặt với hạn chót (deadline) gấp gáp?',
          suggestions: [
            'We prioritized high-impact features and aligned on daily goals to hit the deadline.',
            'We communicated blockers early during daily standups and automated our tests.'
          ]
        },
        {
          reply: 'Fantastic answer! You demonstrated strong technical ownership and clear communication. Do you have any questions for me about our engineering culture?',
          translation: 'Câu trả lời tuyệt vời! Bạn thể hiện tinh thần làm chủ kỹ thuật và giao tiếp rất rõ ràng. Bạn có câu hỏi nào cho tôi về văn hóa kỹ thuật của đội ngũ không?',
          suggestions: [
            'What are the biggest technical milestones your team is aiming for this quarter?',
            'How does your engineering team balance new features with technical debt?'
          ]
        }
      ],
      initialSuggestions: [
        'I recently built a scalable learning app using Flutter Clean Architecture.',
        'Last quarter, I collaborated with my team to optimize our mobile app performance.'
      ]
    },
    {
      id: 'sc_standup',
      title: 'Họp Daily Standup & Báo cáo Blocker',
      roleDescription: 'AI đóng vai Scrum Master điều phối buổi họp sáng.',
      cefr: 'B1',
      targetVocabulary: ['working on', 'blocker', 'prioritize', 'feasible', 'follow up'],
      initialGreeting: 'Good morning! Let us kick off our daily standup. What did you accomplish yesterday and what are you working on today?',
      initialTranslation: 'Chào buổi sáng! Hãy bắt đầu buổi họp Standup nhé. Hôm qua bạn đã hoàn thành gì và hôm nay bạn đang làm phần việc nào?',
      turns: [
        {
          reply: 'Got it, thanks for the clear update! Are you facing any technical blockers that might affect our sprint goal?',
          translation: 'Đã rõ, cảm ơn bản cập nhật của bạn! Bạn có đang gặp trở ngại (blocker) nào có thể ảnh hưởng tới mục tiêu Sprint không?',
          suggestions: [
            'I ran into a minor API blocker, so I will follow up with the backend team today.',
            'No major blocker right now, delivering this feature by Friday is completely feasible.'
          ]
        },
        {
          reply: 'Good call. If the backend team is busy, how should we prioritize your remaining tasks today?',
          translation: 'Hợp lý đấy. Nếu đội Backend đang bận, chúng ta nên ưu tiên các đầu việc còn lại của bạn trong hôm nay như thế nào?',
          suggestions: [
            'I will prioritize the offline UI mode first while waiting for the API fix.',
            'I can finish writing the unit tests so we stay on track.'
          ]
        }
      ],
      initialSuggestions: [
        'Yesterday I completed the login screen, and today I am working on the SRS flashcard module.',
        'I finished the database schema and today I am working on the quiz engine.'
      ]
    },
    {
      id: 'sc_airport',
      title: 'Làm thủ tục Sân bay & Hải quan Quốc tế',
      roleDescription: 'AI đóng vai Nhân viên Quầy Check-in & Hải quan sân bay.',
      cefr: 'A2-B1',
      targetVocabulary: ['aisle seat', 'boarding pass', 'carry-on', 'conference', 'itinerary'],
      initialGreeting: 'Good morning! May I see your passport please? Where are you flying to today, and do you have any checked luggage?',
      initialTranslation: 'Chào buổi sáng! Cho tôi xem hộ chiếu của bạn nhé? Hôm nay bạn bay đi đâu và có hành lý ký gửi nào không?',
      turns: [
        {
          reply: 'Thank you. Would you prefer a window seat or an aisle seat? Also, do you only have this carry-on bag?',
          translation: 'Cảm ơn bạn. Bạn thích ghế cạnh cửa sổ hay ghế cạnh lối đi? Ngoài ra bạn chỉ có chiếc túi xách tay này thôi phải không?',
          suggestions: [
            'Could I have an aisle seat near the front, please? I only have this carry-on.',
            'An aisle seat would be great. Here is my bag for weight check.'
          ]
        },
        {
          reply: 'Here is your boarding pass! Gate 14 starts boarding at 10:30. By the way, at immigration, what is the purpose of your trip?',
          translation: 'Đây là thẻ lên máy bay của bạn! Cổng 14 bắt đầu lên máy bay lúc 10:30. Nhân tiện, khi qua hải quan, mục đích chuyến đi của bạn là gì?',
          suggestions: [
            'I am attending a four-day technology conference and here is my return itinerary.',
            'I am visiting for a one-week vacation and staying at a downtown hotel.'
          ]
        }
      ],
      initialSuggestions: [
        'Here is my passport. I am flying to London and I have one suitcase to check in.',
        'Good morning! I am flying to Singapore and I only have carry-on luggage.'
      ]
    },
    {
      id: 'sc_hotel',
      title: 'Nhận phòng & Yêu cầu Dịch vụ Khách sạn 5 Sao',
      roleDescription: 'AI đóng vai Lễ tân khách sạn The Grand Hotel tại London.',
      cefr: 'A2-B1',
      targetVocabulary: ['reservation', 'complimentary', 'late checkout', 'accommodate', 'luggage'],
      initialGreeting: 'Good evening! Welcome to The Grand London Hotel. How may I assist you with your check-in today?',
      initialTranslation: 'Chào buổi tối! Chào mừng quý khách đến với khách sạn The Grand London. Tôi có thể hỗ trợ gì cho thủ tục nhận phòng của quý khách hôm nay?',
      turns: [
        {
          reply: 'I found your booking for a Deluxe King Room for three nights! Breakfast is complimentary. Do you have any special requests for your stay?',
          translation: 'Tôi đã tìm thấy đặt phòng Deluxe King 3 đêm của quý khách! Bữa sáng hoàn toàn miễn phí đi kèm. Quý khách có yêu cầu đặc biệt nào cho kỳ nghỉ không?',
          suggestions: [
            'Could you accommodate a quiet room on a high floor and a late checkout on Sunday?',
            'That is wonderful! What time is the complimentary breakfast served?'
          ]
        },
        {
          reply: 'Certainly! I have assigned you a quiet room on the 12th floor and noted a late checkout at 1:30 PM. Here is your room key card!',
          translation: 'Chắc chắn rồi ạ! Tôi đã xếp cho quý khách một phòng yên tĩnh trên tầng 12 và ghi chú trả phòng muộn lúc 13:30. Đây là thẻ từ phòng của quý khách!',
          suggestions: [
            'Thank you so much! Could the bellhop help us with our luggage?',
            'Thanks for your great service! Where are the elevators located?'
          ]
        }
      ],
      initialSuggestions: [
        'Hello! I would like to check in. I have a reservation under the name Minh Anh.',
        'Good evening, I booked a double room online under the name Minh Anh.'
      ]
    },
    {
      id: 'sc_cafe',
      title: 'Gọi món & Trò chuyện tại Quán Cà Phê',
      roleDescription: 'AI đóng vai Barista tại quán cà phê Specialty ở New York.',
      cefr: 'A1-A2',
      targetVocabulary: ['oat milk', 'for here', 'to go', 'contactless', 'receipt'],
      initialGreeting: 'Hi there! Welcome to Brooklyn Roasters. What can I get started for you today?',
      initialTranslation: 'Xin chào! Chào mừng bạn đến với Brooklyn Roasters. Hôm nay tôi có thể pha món gì cho bạn nhỉ?',
      turns: [
        {
          reply: 'Sure thing! Would you like that for here or to go? And would you like any pastries to go with your drink?',
          translation: 'Chắc chắn rồi! Bạn muốn dùng tại quán hay mang đi? Và bạn có muốn dùng thêm bánh ngọt nào kèm đồ uống không?',
          suggestions: [
            'For here, please. And could I also get a warm almond croissant?',
            'To go, please. That will be all for today!'
          ]
        },
        {
          reply: 'Awesome, your total comes to $8.50. How would you like to pay today?',
          translation: 'Tuyệt vời, tổng cộng của bạn là 8.50 đô la. Hôm nay bạn muốn thanh toán bằng hình thức nào?',
          suggestions: [
            'I will pay by contactless card, and could I have the receipt please?',
            'Can I tap my phone with Apple Pay? No receipt needed, thank you!'
          ]
        }
      ],
      initialSuggestions: [
        'Could I get a medium iced oat milk latte, less sweet, please?',
        'I would like a hot cappuccino and a glass of water, please.'
      ]
    }
  ],

  pronunciationDrills: [
    {
      id: 'dr_1',
      level: 'B2 • Công nghệ & Kiến trúc',
      sentence: 'We need a scalable architecture for our global users.',
      fullIpa: '/wiː niːd ə ˈskeɪləbl ˈɑːkɪtɛktʃə fɔːr ˈaʊə ˈɡləʊbl ˈjuːzəz/',
      vietnameseMeaning: 'Chúng ta cần một kiến trúc có khả năng mở rộng cho người dùng toàn cầu.',
      words: [
        { word: 'We', ipa: '/wiː/', score: 98, tip: 'Nguyên âm dài /iː/ rõ ràng.' },
        { word: 'need', ipa: '/niːd/', score: 95, tip: 'Bật nhẹ âm đuôi /d/.' },
        { word: 'a', ipa: '/ə/', score: 96, tip: 'Đọc lướt bằng âm schwa /ə/.' },
        { word: 'scalable', ipa: '/ˈskeɪləbl/', score: 82, tip: 'Chú ý nguyên âm đôi /eɪ/ ở âm tiết đầu: /ˈskeɪ-lə-bl/.' },
        { word: 'architecture', ipa: '/ˈɑːkɪtɛktʃə/', score: 68, tip: 'Chữ "ch" đầu đọc là /k/ (/ˈɑː-kɪ-tɛk-tʃə/), không đọc là /tʃ/.' },
        { word: 'for', ipa: '/fɔːr/', score: 94, tip: 'Nối âm mượt với "our".' },
        { word: 'our', ipa: '/ˈaʊə/', score: 92, tip: 'Phát âm chuẩn.' },
        { word: 'global', ipa: '/ˈɡləʊbl/', score: 89, tip: 'Giữ âm /l/ ở cuối bằng cách chạm đầu lưỡi lên chân răng trên.' },
        { word: 'users', ipa: '/ˈjuːzəz/', score: 90, tip: 'Âm cuối /z/ rung dây thanh quản.' }
      ]
    },
    {
      id: 'dr_2',
      level: 'B2 • Họp & Thuyết trình',
      sentence: 'Could you elaborate on the quarterly revenue forecast?',
      fullIpa: '/kʊd juː ɪˈlæbəreɪt ɒn ðə ˈkwɔːtəli ˈrɛvənjuː ˈfɔːkɑːst/',
      vietnameseMeaning: 'Bạn có thể giải thích chi tiết hơn về dự báo doanh thu hàng quý không?',
      words: [
        { word: 'Could', ipa: '/kʊd/', score: 96, tip: 'Nguyên âm ngắn /ʊ/ (chữ l câm).' },
        { word: 'you', ipa: '/juː/', score: 95, tip: 'Có thể nối âm /d_juː/ thành /dʒuː/.' },
        { word: 'elaborate', ipa: '/ɪˈlæbəreɪt/', score: 75, tip: 'Nhấn trọng âm vào âm tiết thứ 2: /ɪ-ˈLÆB-ə-reɪt/.' },
        { word: 'on', ipa: '/ɒn/', score: 97, tip: 'Chuẩn xác.' },
        { word: 'the', ipa: '/ðə/', score: 91, tip: 'Đặt đầu lưỡi giữa hai hàm răng cho âm /ð/.' },
        { word: 'quarterly', ipa: '/ˈkwɔːtəli/', score: 86, tip: 'Trọng âm rơi vào âm đầu /ˈkwɔː-/.' },
        { word: 'revenue', ipa: '/ˈrɛvənjuː/', score: 81, tip: 'Nhấn âm đầu /ˈrɛv-ə-njuː/.' },
        { word: 'forecast', ipa: '/ˈfɔːkɑːst/', score: 93, tip: 'Bật rõ tổ hợp phụ âm cuối /st/.' }
      ]
    },
    {
      id: 'dr_3',
      level: 'A2-B1 • Du lịch & Sân bay',
      sentence: 'Could I have an aisle seat and my boarding pass please?',
      fullIpa: '/kʊd aɪ hæv ən aɪl siːt ænd maɪ ˈbɔːdɪŋ pɑːs pliːz/',
      vietnameseMeaning: 'Cho tôi xin một ghế cạnh lối đi và thẻ lên máy bay nhé?',
      words: [
        { word: 'Could', ipa: '/kʊd/', score: 96, tip: 'Chuẩn.' },
        { word: 'I', ipa: '/aɪ/', score: 98, tip: 'Nối âm /kʊ-daɪ/.' },
        { word: 'have', ipa: '/hæv/', score: 94, tip: 'Âm cuối /v/ răng trên chạm môi dưới.' },
        { word: 'an', ipa: '/ən/', score: 95, tip: 'Nối âm sang "aisle": /ə-naɪl/.' },
        { word: 'aisle', ipa: '/aɪl/', score: 66, tip: 'Cực kỳ lưu ý: Chữ "s" trong "aisle" là ÂM CÂM! Đọc giống hệt "I\'ll" (/aɪl/).' },
        { word: 'seat', ipa: '/siːt/', score: 92, tip: 'Kéo dài nguyên âm /iː/, khép âm /t/.' },
        { word: 'and', ipa: '/ænd/', score: 95, tip: 'Tốt.' },
        { word: 'my', ipa: '/maɪ/', score: 97, tip: 'Tốt.' },
        { word: 'boarding', ipa: '/ˈbɔːdɪŋ/', score: 91, tip: 'Trọng âm đầu /ˈbɔː-/.' },
        { word: 'pass', ipa: '/pɑːs/', score: 94, tip: 'Âm /s/ cuối rõ ràng.' },
        { word: 'please', ipa: '/pliːz/', score: 96, tip: 'Kết thúc bằng âm /z/.' }
      ]
    },
    {
      id: 'dr_4',
      level: 'B1-B2 • Khách sạn & Dịch vụ',
      sentence: 'Please keep your original receipt for a complimentary upgrade.',
      fullIpa: '/pliːz kiːp jɔːr əˈrɪdʒənl rɪˈsiːt fɔːr ə ˌkɒmplɪˈmɛntəri ˈʌpɡreɪd/',
      vietnameseMeaning: 'Vui lòng giữ lại biên lai gốc để được nâng hạng miễn phí.',
      words: [
        { word: 'Please', ipa: '/pliːz/', score: 95, tip: 'Âm /pl/ bật rõ.' },
        { word: 'keep', ipa: '/kiːp/', score: 96, tip: 'Tốt.' },
        { word: 'your', ipa: '/jɔːr/', score: 94, tip: 'Tốt.' },
        { word: 'original', ipa: '/əˈrɪdʒənl/', score: 85, tip: 'Nhấn âm thứ 2 /ə-ˈRɪDƷ-ə-nl/.' },
        { word: 'receipt', ipa: '/rɪˈsiːt/', score: 65, tip: 'Chữ "p" trong "receipt" là ÂM CÂM! Đọc là /rɪ-ˈsiːt/.' },
        { word: 'for', ipa: '/fɔːr/', score: 95, tip: 'Tốt.' },
        { word: 'a', ipa: '/ə/', score: 97, tip: 'Tốt.' },
        { word: 'complimentary', ipa: '/ˌkɒmplɪˈmɛntəri/', score: 77, tip: 'Trọng âm chính rơi vào âm "-MEN-": /ˌkɒm-plɪ-ˈMɛN-tə-ri/.' },
        { word: 'upgrade', ipa: '/ˈʌpɡreɪd/', score: 91, tip: 'Nguyên âm đôi /eɪ/ ở âm thứ hai.' }
      ]
    },
    {
      id: 'dr_5',
      level: 'C1 • IELTS Academic',
      sentence: 'Artificial intelligence has become ubiquitous in modern education.',
      fullIpa: '/ˌɑːtɪˈfɪʃl ɪnˈtɛlɪdʒəns hæz bɪˈkʌm juːˈbɪkwɪtəs ɪn ˈmɒdn ˌɛdʒʊˈkeɪʃən/',
      vietnameseMeaning: 'Trí tuệ nhân tạo đã trở nên phổ biến ở khắp mọi nơi trong nền giáo dục hiện đại.',
      words: [
        { word: 'Artificial', ipa: '/ˌɑːtɪˈfɪʃl/', score: 88, tip: 'Nhấn âm thứ 3 /-ˈfɪʃ-/ với âm /ʃ/ cong môi.' },
        { word: 'intelligence', ipa: '/ɪnˈtɛlɪdʒəns/', score: 90, tip: 'Nhấn âm /-ˈtɛl-/ và kết thúc bằng âm /s/.' },
        { word: 'has', ipa: '/hæz/', score: 96, tip: 'Tốt.' },
        { word: 'become', ipa: '/bɪˈkʌm/', score: 95, tip: 'Tốt.' },
        { word: 'ubiquitous', ipa: '/juːˈbɪkwɪtəs/', score: 72, tip: 'Chữ "u" đầu đọc là /juː/ (không đọc là /ʌ/), nhấn vào /-ˈBɪK-/.' },
        { word: 'in', ipa: '/ɪn/', score: 98, tip: 'Tốt.' },
        { word: 'modern', ipa: '/ˈmɒdn/', score: 93, tip: 'Tốt.' },
        { word: 'education', ipa: '/ˌɛdʒʊˈkeɪʃən/', score: 89, tip: 'Âm "du" phát âm là /dʒʊ/, trọng âm ở /-ˈkeɪ-/.' }
      ]
    }
  ]
};
