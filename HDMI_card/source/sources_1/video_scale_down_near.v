module video_scale_down_near	
(
    input                   vin_clk,
    input                   rst_n,
    input                   frame_vs, // ������Ƶ֡ͬ����λ
    input       [24:0]      vin_dat,      // ������Ƶ����
    input                   vin_valid,    // ������Ƶ������Ч
    output                  vin_ready,    // ����׼����
    output  reg [24:0]      vout_dat,     // �����Ƶ����
    output  reg             vout_valid,   // �����Ƶ������Ч

    input                   vout_ready,   // ���׼����
    input       [15:0]      vin_xres,     // ������Ƶˮƽ�ֱ���
    input       [15:0]      vin_yres,     // ������Ƶ��ֱ�ֱ���
    input       [15:0]      vout_xres,    // �����Ƶˮƽ�ֱ���
    input       [15:0]      vout_yres     // �����Ƶ��ֱ�ֱ���
);

    reg     [31:0]  scaler_height;  // ��ֱ����ϵ��
    reg     [31:0]  scaler_width;   // ˮƽ����ϵ��
    reg     [15:0]  vin_x = 0;      // ������Ƶˮƽ����
    reg     [15:0]  vin_y = 0;      // ������Ƶ��ֱ����
    reg     [31:0]  vout_x = 0;     // �����Ƶˮƽ����
    reg     [31:0]  vout_y = 0;     // �����Ƶ��ֱ����

    assign vin_ready = vout_ready;  // �����ź�

// Ԥ�������ű���
// ���� 1920x1080 ����ֱ���
localparam [31:0] SCALER_1920_WIDTH_1024 = ((1920 << 16) / 1024) + 1;
localparam [31:0] SCALER_1920_HEIGHT_768 = ((1080 << 16) / 768) + 1;
localparam [31:0] SCALER_1920_WIDTH_640  = ((1920 << 16) / 640) + 1;
localparam [31:0] SCALER_1920_HEIGHT_480 = ((1080 << 16) / 480) + 1;
localparam [31:0] SCALER_1920_WIDTH_960  = ((1920 << 16) / 960) + 1;
localparam [31:0] SCALER_1920_HEIGHT_540 = ((1080 << 16) / 540) + 1;
localparam [31:0] SCALER_1920_WIDTH_1280 = ((1920 << 16) / 1280) + 1;
localparam [31:0] SCALER_1920_HEIGHT_720 = ((1080 << 16) / 720) + 1;



// ʹ�ò���ѡ��̶������ű���
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n) begin
        scaler_width  <= 0;
        scaler_height <= 0;
    end else begin
        case ({vin_xres, vin_yres, vout_xres, vout_yres})
            // 1920x1080���룬1920x1080��� (No scaling needed)
            {16'd1920, 16'd1080, 16'd1920, 16'd1080}: begin
                scaler_width  <= (1 << 16);  // No scaling, factor = 1
                scaler_height <= (1 << 16);
            end
            // 1920x1080���룬1024x768���
            {16'd1920, 16'd1080, 16'd1024, 16'd768}: begin
                scaler_width  <= SCALER_1920_WIDTH_1024;
                scaler_height <= SCALER_1920_HEIGHT_768;
            end
            // 1920x1080���룬640x480���
            {16'd1920, 16'd1080, 16'd640, 16'd480}: begin
                scaler_width  <= SCALER_1920_WIDTH_640;
                scaler_height <= SCALER_1920_HEIGHT_480;
            end
            // 1920x1080���룬960x540���
            {16'd1920, 16'd1080, 16'd960, 16'd540}: begin
                scaler_width  <= SCALER_1920_WIDTH_960;
                scaler_height <= SCALER_1920_HEIGHT_540;
            end
            // 1920x1080���룬1280x720���
            {16'd1920, 16'd1080, 16'd1280, 16'd720}: begin
                scaler_width  <= SCALER_1920_WIDTH_1280;
                scaler_height <= SCALER_1920_HEIGHT_720;
            end
            default: begin
                scaler_width  <= 0;
                scaler_height <= 0;
            end
        endcase
    end
end


reg frame_vs_prev;      // ���ڴ洢frame_vs����һ��״̬
wire frame_vs_rising;   // ���ڱ�ʾframe_vs�������ؼ����

// ��ʱ�ӵ������ؽ��м��
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n) begin
        frame_vs_prev <= 0;       // ��λʱ��֮ǰ״̬��Ϊ0
    end else begin
        frame_vs_prev <= frame_vs; // ���浱ǰframe_vs��״̬��frame_vs_prev
    end
end

// ��������أ���ǰframe_vsΪ1����һ��״̬Ϊ0ʱ����������Ч
assign frame_vs_rising = frame_vs & ~frame_vs_prev;


// ����������Ƶ��ˮƽ�ʹ�ֱ������
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n || frame_vs_rising) begin
        vin_x <= 0;
        vin_y <= 0;
    end else if (vin_valid && vout_ready) begin
        if (vin_x < vin_xres - 1)
            vin_x <= vin_x + 1;
        else begin
            vin_x <= 0;
            vin_y <= vin_y + 1;
        end
    end
end

// ���������Ƶ����������
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n || frame_vs_rising) begin
        vout_x <= 0;
        vout_y <= 0;
    end else if (vin_valid && vout_ready) begin
        if (vin_x < vin_xres - 1) begin
            if (vout_x[31:16] <= vin_x)
                vout_x <= vout_x + scaler_width;
        end else begin
            vout_x <= 0;
            if (vout_y[31:16] <= vin_y)
                vout_y <= vout_y + scaler_height;
        end
    end
end

// �ٽ���С�㷨���жϱ������ز����
always @(posedge vin_clk or negedge rst_n) begin
    if (!rst_n || frame_vs_rising) begin
        vout_dat   <= 0;
        vout_valid <= 0;
    end else if (vout_ready) begin
        if (vout_x[31:16] == vin_x && vout_y[31:16] == vin_y) begin
            vout_valid <= vin_valid; // ���������Ч
            vout_dat   <= vin_dat;   // �����õ��������
        end else begin
            vout_valid <= 0;         // �������Ч������������
        end
    end
end

endmodule
