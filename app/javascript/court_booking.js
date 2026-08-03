const ALL_SLOTS = [
  { start: 6, end: 7, label: "6.00-7.00" },
  { start: 7, end: 8, label: "7.00-8.00" },
  { start: 8, end: 9, label: "8.00-9.00" },
  { start: 9, end: 10, label: "9.00-10.00" },
  { start: 10, end: 11, label: "10.00-11.00" },
  { start: 11, end: 12, label: "11.00-12.00" },
  { start: 12, end: 13, label: "12.00-13.00" },
  { start: 13, end: 14, label: "13.00-14.00" },
  { start: 14, end: 15, label: "14.00-15.00" },
  { start: 15, end: 16, label: "15.00-16.00" },
  { start: 16, end: 17, label: "16.00-17.00" },
  { start: 17, end: 18, label: "17.00-18.00" },
  { start: 18, end: 19, label: "18.00-19.00" },
  { start: 19, end: 20, label: "19.00-20.00" },
  { start: 20, end: 21, label: "20.00-21.00" },
  { start: 21, end: 22, label: "21.00-22.00" },
  { start: 22, end: 23, label: "22.00-23.00" },
  { start: 23, end: 24, label: "23.00-24.00" }
];

let existingBookings = [];
let closedDates = [];
const selectedSlots = {};

let _courtBookingInitialized = false;
function initCourtBooking() {
  if (_courtBookingInitialized) return;
  _courtBookingInitialized = true;
  
  const pageWrapper = document.querySelector(".page-wrapper[data-bookings]");
  if (!pageWrapper) {
    _courtBookingInitialized = false;
    return;
  }

  try {
    existingBookings = JSON.parse(pageWrapper.dataset.bookings || "[]");
    closedDates = JSON.parse(pageWrapper.dataset.closedDates || "[]");
  } catch (e) {
    existingBookings = [];
    closedDates = [];
  }

  // Bind date pickers
  document.querySelectorAll(".court-date-picker").forEach(input => {
    const courtId = input.dataset.courtId;
    
    // Initial check on load
    checkAndApplyDate(input, courtId);

    // Check on change
    input.addEventListener("change", (e) => {
      checkAndApplyDate(e.target, courtId);
    });
  });

  // Bind booking buttons
  document.querySelectorAll("button[data-testid='booking-btn']").forEach(btn => {
    btn.addEventListener("click", () => {
      const courtId = btn.dataset.courtId;
      const courtName = btn.dataset.courtName;
      handleBookingClick(courtId, courtName);
    });
  });
}

function checkAndApplyDate(input, courtId) {
  const selectedDateStr = input.value;
  const btn = document.querySelector(`button[data-testid='booking-btn'][data-court-id='${courtId}']`);

  if (!selectedDateStr) return;
  
  const selectedDate = new Date(selectedDateStr);
  selectedDate.setHours(0,0,0,0);
  
  const today = new Date();
  today.setHours(0,0,0,0);

  if (selectedDate < today) {
    input.value = "";
    document.getElementById(`slots-${courtId}`).innerHTML = "<p style='color: red; font-weight: bold;'>ไม่สามารถจองย้อนหลังได้</p>";
    if (btn) {
      btn.disabled = true;
      btn.classList.add("cursor-not-allowed", "opacity-50");
    }
    return;
  }
  
  const isClosed = closedDates.some(range => {
    const start = new Date(range.start_date);
    start.setHours(0,0,0,0);
    const end = new Date(range.end_date);
    end.setHours(0,0,0,0);
    return selectedDate >= start && selectedDate <= end;
  });

  if (isClosed) {
    input.value = "";
    document.getElementById(`slots-${courtId}`).innerHTML = "<p style='color: red; font-weight: bold;'>ไม่สามารถจองได้ เนื่องจากตรงกับช่วงเวลาที่สนามปิดปรับปรุง</p>";
    if (btn) {
      btn.disabled = true;
      btn.classList.add("cursor-not-allowed", "opacity-50");
    }
    return;
  }
  
  if (btn) {
    btn.disabled = false;
    btn.classList.remove("cursor-not-allowed", "opacity-50");
  }
  updateAvailableSlots(courtId, input.value);
}

function updateAvailableSlots(courtId, selectedDate) {
  const container = document.getElementById(`slots-${courtId}`);
  if (!container || !selectedDate) return;

  const courtBookings = existingBookings.filter(b => b.cord_id == courtId && b.date === selectedDate);

  container.innerHTML = "";

  ALL_SLOTS.forEach(slot => {
    const isBooked = courtBookings.some(b => slot.start < b.end_hour && slot.end > b.start_hour);
    
    const pill = document.createElement("button");
    pill.type = "button";
    
    if (isBooked) {
      pill.className = "slot-pill booked";
      pill.disabled = true;
      pill.textContent = `${slot.label} (Booked)`;
    } else {
      pill.className = "slot-pill";
      if (selectedSlots[courtId] === slot.label) {
        pill.classList.add("active");
      }
      pill.textContent = slot.label;
      pill.addEventListener("click", () => {
        container.querySelectorAll(".slot-pill").forEach(p => p.classList.remove("active"));
        pill.classList.add("active");
        selectedSlots[courtId] = slot.label;
      });
    }
    
    container.appendChild(pill);
  });
}

async function handleBookingClick(courtId, courtName) {
  const selectedSlot = selectedSlots[courtId];
  const dateInput = document.getElementById(`date-${courtId}`);
  const selectedDate = dateInput ? dateInput.value : "";

  if (!selectedSlot) {
    alert("กรุณาเลือกเวลาที่ต้องการจอง");
    return;
  }

  const phoneInput = document.getElementById(`phone-${courtId}`);
  const phone = phoneInput ? phoneInput.value.trim() : "";

  if (!phone) {
    alert("กรุณากรอกเบอร์โทรศัพท์เพื่อทำการจอง");
    if (phoneInput) phoneInput.focus();
    return;
  }

  const confirmMsg = `ยืนยันการจองสนาม ${courtName}\nวันที่: ${selectedDate}\nเวลา: ${selectedSlot}\nเบอร์โทรศัพท์: ${phone}\nราคา: 500 บาท`;
  if (confirm(confirmMsg)) {
    const [startStr] = selectedSlot.split("-");
    const startHour = parseInt(startStr);
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    try {
      const response = await fetch("/bookings", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken || ""
        },
        body: JSON.stringify({
          cord_id: courtId,
          date: selectedDate,
          start_hour: startHour,
          account_number: "1234567890",
          name_account: "Customer",
          phone: phone
        })
      });

      const data = await response.json();

      if (response.ok && data.status === "success") {
        alert("จองสำเร็จ ระบบได้ทำการหักเครดิต 500 บาทเรียบร้อยแล้ว");
        window.location.reload();
      } else {
        alert("เกิดข้อผิดพลาด: " + (data.errors ? data.errors.join(", ") : "กรุณาลองใหม่อีกครั้ง"));
      }
    } catch (err) {
      console.error(err);
      alert("เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง");
    }
  }
}

document.addEventListener("turbo:load", initCourtBooking);
document.addEventListener("DOMContentLoaded", initCourtBooking);
