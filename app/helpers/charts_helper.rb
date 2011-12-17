module ChartsHelper
  NL_FIELDS = %w(finishs_count reads_count fails_count bounces_count sendings_per_second)

  def newsletters_chart(newsletters)
    {}.tap do |data|
      NL_FIELDS.each do |method|
        data[method] = []
      end
      newsletters.each do |newsletter|
        date = newsletter.delivery_started_at.to_i
        NL_FIELDS.each do |method|
          data[method] << [date, newsletter.send(method)]
        end
      end
    end
  end

  def recipients_chart(account, offset = 1.day)
    {}.tap do |data|
      data[:pending] = {}
      data[:confirmed] = {}
      data[:deleted] = {}

      account.recipients.each do |recipient|
        date_c = (recipient.created_at.to_i / offset) * offset
        date_u = (recipient.updated_at.to_i / offset) * offset
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

  def recipients_chart2(account)
    {
      :pending   => get_recipients(account.id, 'pending', 'created_at'),
      :confirmed => get_recipients(account.id, ['confirmed', 'deleted']),
      :deleted   => get_recipients(account.id, 'deleted', 'updated_at'),
    }
  end

  #private
  def get_recipients(account_id, state, field = 'created_at')
    Recipient.connection.select_rows <<-SQL
      SELECT
        UNIX_TIMESTAMP(DATE_FORMAT(#{field}, '%Y-%m-%d')) + 3600 AS `date`,
        COUNT(*) AS cnt
      FROM recipients
      WHERE state = '#{state}'
      GROUP BY `date`
      ORDER BY `date` ASC
    SQL
  end

  def get_recipients2(account_id, states = [])
    Recipient.connection.select_rows <<-SQL
      SELECT
       UNIX_TIMESTAMP(`date`) + 3600 AS `date`,
       MAX(IF(cnt > 0,cnt,0)) + Min(IF(cnt < 0,cnt,0)) AS cnt
      FROM
        (SELECT
           DATE_FORMAT(created_at, '%Y-%m-%d') AS `date`,
           COUNT(*) AS cnt
         FROM recipients
         WHERE account_id = #{account_id} AND state IN('#{states.join("','")}')
         GROUP BY `date`

        UNION

         SELECT
           DATE_FORMAT(updated_at, '%Y-%m-%d') AS `date`,
           -1 * COUNT(*) AS cnt
         FROM recipients
         WHERE account_id = #{account_id} AND state = '#{states.last}'
         GROUP BY `date`) AS u
      GROUP BY `date`
      ORDER BY `date`
    SQL
  end

end
