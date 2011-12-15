module ChartsHelper
  NL_FIELDS = %w(deliveries_count reads_count fails_count bounces_count sendings_per_second)

  def newsletters_chart(newsletters)
    {}.tap do |data|
      NL_FIELDS.each do |method|
        data[method] = []
      end
      newsletters.each do |newsletter|
        date = newsletter.delivery_started_at.to_i * 1000
        NL_FIELDS.each do |method|
          data[method] << [date, newsletter.send(method)]
        end
      end
    end
  end

  def recipients_chart(recipients, offset = 1.week)
    {}.tap do |data|
      data[:pending] = {}
      data[:confirmed] = {}
      data[:deleted] = {}

      recipients.each do |recipient|
        date_c = (recipient.created_at.to_i / offset) * 1000 * offset
        date_u = (recipient.updated_at.to_i / offset) * 1000 * offset
        if recipient.deleted?
          data[:deleted][date_u] ||= 0
          data[:deleted][date_u] += 1
          if date_c != date_u
            data[:confirmed][date_c] ||= 0
            data[:confirmed][date_c] += 1
            data[:confirmed][date_u] ||= 0
            data[:confirmed][date_u] -= 1
          end
        elsif recipient.confirmed?
          data[:confirmed][date_c] ||= 0
          data[:confirmed][date_c] += 1
          # if date_c != date_u
          #   data[:pending][date_c] ||= 0
          #   data[:pending][date_c] += 1
          #   data[:pending][date_u] ||= 0
          #   data[:pending][date_u] -= 1
          # end
        elsif recipient.pending?
          data[:pending][date_c] ||= 0
          data[:pending][date_c] += 1
        end
      end
    end
  end

  def accumulate(data)
    sum = 0
    data.to_a.sort { |a,b| a.first <=> b.first }.map do |date, diff|
      sum += diff
      [date, sum]
    end
  end
end
