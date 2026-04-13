class InvoiceReminderJob < ApplicationJob
  queue_as :default

  # Sends reminders for unpaid invoices at 3, 7, and 14 days past issued date
  def perform
    [3, 7, 14].each do |days|
      overdue = Invoice.where(status: :issued)
                       .where("issued_at BETWEEN ? AND ?", (days + 1).days.ago, days.days.ago)
                       .includes(booking: { customer: [], service: :provider })

      overdue.each do |invoice|
        UserMailer.invoice_reminder(invoice, days).deliver_later

        # Mark overdue after 14 days
        invoice.update(status: :overdue) if days >= 14
      end

      Rails.logger.info "InvoiceReminderJob: Sent #{overdue.count} reminders for #{days}-day overdue invoices"
    end
  end
end
