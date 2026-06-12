class AppStrings {
  const AppStrings._();

  static const appName = 'JobConnect';
  static const home = 'Trang chủ';
  static const search = 'Tìm việc';
  static const applications = 'Đơn ứng tuyển';
  static const conversations = 'Tin nhắn';
  static const profile = 'Hồ sơ';
  static const login = 'Đăng nhập';
  static const register = 'Đăng ký';
  static const loading = 'Đang tải...';
  static const errorGeneral = 'Đã có lỗi xảy ra';
  static const retry = 'Thử lại';
  static const forgotPasswordSuccess =
      'Nếu email này tồn tại trong hệ thống, bạn sẽ nhận được link đặt lại mật khẩu trong vài phút.';

  // Profile — T-10
  static const chooseFromGallery = 'Chọn từ thư viện';
  static const takePhoto = 'Chụp ảnh';
  static const changeAvatar = 'Thay đổi ảnh đại diện';
  static const editProfile = 'Chỉnh sửa hồ sơ';
  static const saveChanges = 'Lưu thay đổi';
  static const logout = 'Đăng xuất';
  static const profileUpdated = 'Hồ sơ đã được cập nhật';
  static const fullNameLabel = 'Họ tên';
  static const headlineLabel = 'Tiêu đề';
  static const bioLabel = 'Giới thiệu';
  static const locationLabel = 'Địa điểm';

  // T-11: Work Experience, Education, Certificate
  static const workExperience = 'Kinh nghiệm làm việc';
  static const education = 'Học vấn';
  static const certificate = 'Chứng chỉ';
  static const noData = 'Chưa có thông tin';
  static const currentlyWorking = 'Đang làm việc tại đây';
  static const currently = 'Hiện tại';
  static const toDateError = 'Ngày kết thúc phải sau ngày bắt đầu';
  static const confirmDelete = 'Xác nhận xóa';
  static const confirmDeleteMessage = 'Bạn có chắc muốn xóa mục này?';
  static const delete = 'Xóa';
  static const cancel = 'Hủy';

  // T-12: Skills
  static const skills = 'Kỹ năng';
  static const selectLevel = 'Chọn trình độ';
  static const levelBeginner = 'Cơ bản';
  static const levelIntermediate = 'Trung bình';
  static const levelAdvanced = 'Nâng cao';
  static const searchSkill = 'Tìm kỹ năng...';
  static const deleteSkillMessage = 'Bạn có chắc muốn xóa kỹ năng này?';

  // T-13: Company
  static const companyEmptyTitle = 'Thiết lập hồ sơ công ty';
  static const companyEmptySubtitle =
      'Tạo hồ sơ công ty để bắt đầu đăng tin tuyển dụng';
  static const createCompany = 'Tạo hồ sơ công ty';
  static const editCompany = 'Chỉnh sửa hồ sơ công ty';
  static const companyName = 'Tên công ty';
  static const companyDescription = 'Mô tả công ty';
  static const companyWebsite = 'Website';
  static const companySize = 'Quy mô công ty';
  static const companyProvince = 'Tỉnh / Thành phố';
  static const companyCreated = 'Tạo hồ sơ công ty thành công';
  static const companyUpdated = 'Cập nhật hồ sơ công ty thành công';
  static const changeLogo = 'Thay đổi logo công ty';
  static const companyLogoPlaceholder = 'Logo công ty';
  static const companyProfile = 'Hồ sơ công ty';

  // T-13: Recruiter shell tabs
  static const recruiterHome = 'Trang chủ';
  static const myPosts = 'Tin của tôi';

  // T-14: Job Post Creation
  static const createJobPost = 'Đăng tin tuyển dụng';
  static const saveDraft = 'Lưu nháp';
  static const draftSaved = 'Đã lưu nháp';

  // T-15: Job Post Edit + List
  static const editJobPost = 'Chỉnh sửa tin';
  static const myJobPostsTitle = 'Tin của tôi';
  static const tabDraft = 'Nháp';
  static const tabActive = 'Đang hoạt động';
  static const tabClosed = 'Đã đóng';
  static const publish = 'Đăng tin';
  static const publishConfirmTitle = 'Đăng tin tuyển dụng?';
  static const publishConfirmMessage =
      'Tin sẽ hiển thị công khai cho ứng viên sau khi đăng.';
  static const close = 'Đóng tin';
  static const closeConfirmTitle = 'Đóng tin tuyển dụng?';
  static const closeConfirmMessage =
      'Ứng viên sẽ không thể ứng tuyển sau khi đóng tin.';
  static const discard = 'Xóa nháp';
  static const discardConfirmTitle = 'Xóa tin nháp?';
  static const discardConfirmMessage =
      'Tin nháp sẽ bị xóa. Bạn không thể khôi phục.';
  static const resubmit = 'Đăng lại';
  static const removedByAdmin = 'Bị gỡ bởi Admin';
  static const jobPostPublished = 'Đã đăng tin thành công';
  static const jobPostClosed = 'Đã đóng tin';
  static const jobPostDiscarded = 'Đã xóa tin nháp';
  static const jobPostUpdated = 'Đã cập nhật tin';
  static const jobPostResubmitted = 'Đã đăng lại tin';
  static const emptyDraft = 'Chưa có tin nháp';
  static const emptyActive = 'Chưa có tin đang hoạt động';
  static const emptyClosed = 'Chưa có tin đã đóng';
  static const statusDraft = 'Nháp';
  static const statusActive = 'Đang hoạt động';
  static const statusClosed = 'Đã đóng';
  static const statusRejected = 'Bị từ chối';
  static const applicants = 'ứng viên';
  static const confirm = 'Xác nhận';
  static const status = 'Trạng thái';
  static const jobTitle = 'Tên tin tuyển dụng';
  static const jobDescription = 'Mô tả công việc';
  static const jobDescriptionHint = 'Mô tả chi tiết công việc, quyền lợi...';
  static const jobRequirements = 'Yêu cầu ứng viên';
  static const jobRequirementsHint = 'Kỹ năng, kinh nghiệm, học vấn...';
  static const salaryRange = 'Mức lương';
  static const salaryFrom = 'Từ';
  static const salaryTo = 'Đến';
  static const salaryMillionPerMonth = 'triệu/tháng';
  static const showSalary = 'Hiển thị mức lương cho ứng viên';
  static const salaryHidden = 'Bạn sẽ thích nó!';
  static const jobType = 'Loại hình';
  static const jobCategory = 'Ngành nghề';
  static const selectCategory = 'Chọn ngành nghề';
  static const requiredSkills = 'Kỹ năng yêu cầu';
  static const addSkill = 'Thêm kỹ năng';
  static const skillCount = '/ 15';
  static const jobLocation = 'Địa điểm làm việc';
  static const remoteWork = 'Làm việc từ xa';
  static const province = 'Tỉnh / Thành phố';
  static const district = 'Quận / Huyện';
  static const address = 'Địa chỉ cụ thể';
  static const addressHint = 'Số nhà, đường... (không bắt buộc)';
  static const expiresAt = 'Hạn nộp hồ sơ';
  static const selectExpiryDate = 'Chọn hạn nộp hồ sơ';
  static const unsavedChangesTitle = 'Thay đổi chưa lưu';
  static const unsavedChangesMessage =
      'Bạn có chắc muốn rời khỏi trang? Thay đổi sẽ bị mất.';
  static const stay = 'Ở lại';
  static const leave = 'Rời khỏi';
  static const noCompanyGuardMessage =
      'Vui lòng tạo hồ sơ công ty trước khi đăng tin.';
  static const selectSkill = 'Chọn kỹ năng';

  // T-16: Job Search
  static const searchHint = 'Tìm theo tên tin, mô tả, công ty...';
  static const filters = 'Bộ lọc';
  static const applyFilters = 'Áp dụng bộ lọc';
  static const clearAll = 'Xóa tất cả';
  static const noResults = 'Không tìm thấy việc làm phù hợp';
  static const clearFilters = 'Xóa bộ lọc';
  static const jobResultsCount = 'việc làm';
  static const loadMoreError = 'Có lỗi xảy ra. Thử lại';
  static const seekerSalaryHidden = 'You will love it <3';
  static const postedJustNow = 'Vừa đăng';
  static const hoursAgo = 'giờ trước';
  static const daysAgo = 'ngày trước';
  static const weeksAgo = 'tuần trước';

  // T-17/T-18: Job Detail + Bookmark
  static const jobDetail = 'Chi tiết tin tuyển dụng';
  static const unavailableJobPost =
      'Tin tuyển dụng không còn khả dụng hoặc đã đóng.';
  static const bookmarkList = 'Bookmark';
  static const noBookmarks = 'Bạn chưa lưu Job Post nào';
  static const noBookmarksSubtitle =
      'Các Job Post đã lưu sẽ xuất hiện tại đây.';
  static const apply = 'Apply';
  static const comingSoon = 'Sắp ra mắt';
  static const companyInfo = 'Thông tin công ty';
  static const jobOverview = 'Tổng quan';
  static const unavailableBookmark = 'Job Post này không còn khả dụng.';

  // T-19 → T-23: Application flow
  static const resume = 'Resume';
  static const resumes = 'Resume của bạn';
  static const resumeManager = 'Quản lý Resume';
  static const createResume = 'Tạo Resume';
  static const uploadResumePdf = 'Upload PDF';
  static const resumeBuilder = 'CV Builder';
  static const resumePreview = 'Xem trước Resume';
  static const resumeTitle = 'Tên Resume';
  static const resumeTitleHint = 'Ví dụ: CV Flutter Developer';
  static const professionalTitle = 'Vị trí mong muốn';
  static const contactEmail = 'Email liên hệ';
  static const summary = 'Tóm tắt';
  static const summaryHint =
      'Viết ngắn gọn về thế mạnh và mục tiêu nghề nghiệp';
  static const oneItemPerLine = 'Mỗi dòng là một mục';
  static const firstResumeDefault = 'Resume đầu tiên sẽ tự động là mặc định';
  static const setDefaultResume = 'Đặt làm mặc định';
  static const defaultResume = 'Mặc định';
  static const builderResume = 'Resume tạo trong app';
  static const uploadedResume = 'Resume PDF đã upload';
  static const previewPdf = 'Xem PDF';
  static const editResume = 'Chỉnh sửa Resume';
  static const replacePdf = 'Thay PDF';
  static const deleteResume = 'Xóa Resume';
  static const saveResume = 'Lưu Resume';
  static const resumeSaved = 'Đã lưu Resume';
  static const resumeUpdated = 'Đã cập nhật Resume';
  static const resumeDeleted = 'Đã xóa Resume';
  static const resumeUploaded = 'Đã upload Resume';
  static const resumeDefaultUpdated = 'Đã cập nhật Resume mặc định';
  static const resumeRequired = 'Vui lòng chọn Resume';
  static const pickPdf = 'Chọn file PDF';
  static const pdfOnly = 'Chỉ hỗ trợ file PDF';
  static const pdfMaxSize = 'PDF phải nhỏ hơn hoặc bằng 5MB';
  static const noResumes = 'Bạn chưa có Resume nào';
  static const noResumesSubtitle =
      'Tạo Resume trong app hoặc upload PDF để bắt đầu apply.';
  static const applicationSubmitted = 'Đã nộp đơn ứng tuyển';
  static const applicationUpdated = 'Đã cập nhật đơn ứng tuyển';
  static const applicationResubmitted = 'Đã nộp lại đơn ứng tuyển';
  static const applicationBlocked =
      'Bạn không thể chỉnh sửa Application ở trạng thái hiện tại';
  static const applicationWithdrawn = 'Đã rút đơn ứng tuyển';
  static const duplicateApplication = 'Bạn đã apply Job Post này trước đó';
  static const coverLetter = 'Cover letter';
  static const coverLetterHint =
      'Viết vài dòng giới thiệu bản thân (không bắt buộc)';
  static const submitApplication = 'Nộp đơn ứng tuyển';
  static const myApplications = 'Đơn ứng tuyển của tôi';
  static const applicationDetail = 'Chi tiết Application';
  static const noApplications = 'Bạn chưa có đơn ứng tuyển nào';
  static const withdrawApplication = 'Rút đơn';
  static const withdrawConfirmTitle = 'Rút đơn ứng tuyển?';
  static const withdrawConfirmMessage =
      'Bạn chỉ có thể rút lại khi đơn đang ở trạng thái "Đang chờ".';
  static const statusPending = 'Đang chờ';
  static const statusReviewing = 'Đang xem xét';
  static const statusInterview = 'Phỏng vấn';
  static const statusRejectedApplication = 'Đã từ chối';
  static const statusWithdrawn = 'Đã rút';
  static const statusAccepted = 'Đã nhận';
  static const all = 'Tất cả';
  static const interviewSchedule = 'Lịch phỏng vấn';
  static const scheduleInterview = 'Đặt lịch phỏng vấn';
  static const interviewScheduled = 'Đã lưu lịch phỏng vấn';
  static const applied = 'Đã apply';
  static const editApplication = 'Chỉnh sửa đơn ứng tuyển';
  static const interviewLocation = 'Địa điểm phỏng vấn';
  static const interviewNote = 'Ghi chú phỏng vấn';
  static const scheduledAt = 'Ngày giờ phỏng vấn';
  static const pickDateTime = 'Chọn ngày giờ';

  // T-28 / T-29: Chat
  static const chat = 'Nhắn tin';
  static const noConversations = 'Chưa có cuộc trò chuyện nào';
  static const noConversationsSubtitle =
      'Bắt đầu trò chuyện từ chi tiết tin tuyển dụng hoặc đơn ứng tuyển.';
  static const noMessages = 'Chưa có tin nhắn nào';
  static const chatInputHint = 'Nhập tin nhắn...';
  static const chatNeedApplyFirst =
      'Bạn cần ứng tuyển trước khi nhắn tin với Nhà tuyển dụng.';
  static const chatStatusNotAllowed =
      'Không thể bắt đầu cuộc trò chuyện ở trạng thái này.';
  static const chatToday = 'Hôm nay';
  static const chatYesterday = 'Hôm qua';

  // T-30 / T-31 / T-32: Notifications
  static const notifications = 'Thông báo';
  static const noNotifications = 'Chưa có thông báo';
  static const noNotificationsSubtitle = 'Thông báo sẽ xuất hiện tại đây.';
  static const markAllRead = 'Đánh dấu đã đọc';

  // T-27: Skill Gap
  static const skillGapTitle = 'Kỹ năng yêu cầu';
  static const skillGapAskAdvice = 'AI gợi ý lộ trình học';
  static const skillGapAdviceTitle = 'Gợi ý lộ trình học';
  static const skillGapHideAdvice = 'Ẩn gợi ý';
  static const skillGapShowAdvice = 'Hiện gợi ý';
  static const skillGapContextChanged =
      'Hồ sơ hoặc kỹ năng đã thay đổi. Hãy tạo lại gợi ý để nhận lộ trình phù hợp hơn.';
  static const skillGapAdviceError = 'Chưa thể lấy gợi ý học tập lúc này.';
  static const skillGapAdviceRetry = 'Thử lại';
  static const skillGapEmpty = 'Tin tuyển dụng này chưa liệt kê kỹ năng yêu cầu.';
  static const skillGapAdviceRateLimited =
      'Bạn đã gửi quá nhiều yêu cầu gợi ý. Thử lại sau ít phút.';

  // T-24: AI Embedding
  static const aiMatchUpdated = 'AI đã cập nhật Profile Embedding.';
  static const aiMatchReady = 'AI Match đã sẵn sàng.';
  static const aiMatchRateLimited = 'Vui lòng thử lại sau vài phút.';
  static const aiMatchMissingData =
      'Hãy thêm headline, kỹ năng hoặc kinh nghiệm trước khi bật AI Match.';
  static const aiMatchError = 'Đã có lỗi khi cập nhật AI Match.';
  static const aiMatchRefresh = 'Cập nhật AI Match';

  // T-25: AI Suggestions
  static const aiSuggestionsTitle = 'Gợi ý bởi AI';
  static const aiSuggestionsSubtitle =
      'Match Score dựa trên Profile, kỹ năng và mô tả Job Post.';
  static const aiStaleWarning =
      'Gợi ý đã cũ hơn 24 giờ. Hãy cập nhật để nhận kết quả mới nhất.';
  static const aiUpdateSuggestions = 'Cập nhật';
  static const aiOnboardingTitle = 'AI Gợi ý';
  static const aiOnboardingBody =
      'JobConnect sẽ phân tích Profile và so sánh với hàng trăm tin tuyển dụng để tìm việc phù hợp nhất.';
  static const aiCreateSuggestions = 'Tạo gợi ý';
  static const aiCompleteProfileTitle =
      'Hoàn thiện Profile để nhận gợi ý tốt hơn';
  static const aiCompleteProfileBody =
      'Thêm headline, kỹ năng hoặc kinh nghiệm để JobConnect hiểu hướng đi của bạn.';
  static const aiUpdateProfile = 'Cập nhật Profile';
  static const aiPreparingTitle = 'Gợi ý đang được chuẩn bị';
  static const aiPreparingBody =
      'Một số Job Post cần được đồng bộ AI trước khi có Match Score.';
  static const aiViewLatestJobs = 'Xem việc mới nhất';
  static const aiSuggestionsError = 'Không tải được gợi ý AI';
  static const aiSuggestionsErrorBody =
      'Hãy thử lại để tiếp tục khám phá cơ hội phù hợp.';
  static const latestJobs = 'Việc mới nhất';
  static const noJobPostsYet = 'Chưa có tin tuyển dụng nào.';
  static const splashTagline = 'Kết nối cơ hội của bạn';
  static const themeAppearance = 'Giao diện';
  static const themeSystem = 'Theo hệ thống';
  static const themeLight = 'Sáng';
  static const themeDark = 'Tối';
  static const matchVeryRelevant = 'Rất phù hợp';
  static const matchRelevant = 'Phù hợp';
  static const matchPotential = 'Có tiềm năng';
  static const matchExploreMore = 'Khám phá thêm';
  static const aiMatchExplanationTitle = 'Vì sao việc này phù hợp với bạn?';
  static const aiMatchExplanationLoading =
      'AI đang phân tích mức độ phù hợp...';
  static const aiMatchExplanationFootnote =
      'AI phân tích từ Profile và yêu cầu Job Post.';
  static const aiMatchExplanationError = 'Chưa thể tạo giải thích lúc này.';
  static const aiMatchExplanationRetry = 'Thử lại';
  static const aiMatchExplanationRateLimited =
      'Bạn đã xem nhiều giải thích AI. Thử lại sau ít phút.';
  static const aiNextStep = 'Gợi ý tiếp theo';
  static const applicantsPageTitle = 'Ứng viên';
  static const applicantDetail = 'Chi tiết ứng viên';
  static const internalNote = 'Ghi chú nội bộ';
  static const internalNoteHint = 'Chỉ Recruiter nhìn thấy';
  static const saveNote = 'Lưu ghi chú';
  static const noteSaved = 'Đã lưu ghi chú';
  static const shortlist = 'Shortlist';
  static const invite = 'Invite';
  static const hire = 'Tuyển';
  static const reject = 'Reject';
  static const noApplicants = 'Chưa có ứng viên nào cho Job Post này';
  static const viewApplicants = 'Xem ứng viên';
  static const viewResume = 'Xem Resume';
  static const openResume = 'Mở Resume';
  static const updateStatus = 'Cập nhật trạng thái';
  static const deleteResumeConfirmTitle = 'Xóa Resume?';
  static const deleteResumeConfirmMessage = 'Bạn có chắc muốn xóa Resume này?';
}
