USE [QuanLyKhachSan]
GO

-- Revenue Report
ALTER PROCEDURE SP_RevenueReport (@option NVARCHAR(10),@hotelname NVARCHAR(50), @m INT, @y INT)
AS BEGIN
DECLARE @sqlstring nvarchar(1500), @input nvarchar(100)
IF(@option = N'Tháng') --báo cáo doanh thu theo tháng
	BEGIN
		IF(@m IS NOT NULL AND @y IS NULL) ---chỉ theo tháng (cho trước)

		BEGIN
			SET @sqlstring = 'SELECT K.maKS, K.tenKS, DATEPART(MONTH,H.ngayThanhToan) as Thang, SUM(H.tongTien) as DoanhThu
						      FROM HoaDon H, DatPhong D, LoaiPhong L, KhachSan K
						      WHERE H.maDP=D.maDP AND D.maLoaiPhong=L.maLoaiPhong AND L.maKS=K.maKS AND DATEPART(MONTH,H.ngayThanhToan) = @m'
			---IF(@hotelname IS NULL) ---không báo cáo theo khách sạn --không làm gì cả
			IF(@hotelname IS NOT NULL)---báo cáo theo khách sạn
				SET @sqlstring = @sqlstring  + ' AND K.tenKS like N''%' +@hotelname + '%'''
			---thêm phần group by và order
			SET @sqlstring = @sqlstring + ' GROUP BY DATEPART(MONTH,H.ngayThanhToan), K.maKS, K.tenKS'
			SET @sqlstring = @sqlstring + ' ORDER BY K.maKS'
		END

		ELSE ---theo tháng, năm

		BEGIN
			SET @sqlstring = 'SELECT K.maKS, K.tenKS, DATEPART(MONTH,H.ngayThanhToan) as Thang, DATEPART(YEAR,H.ngayThanhToan) as Nam,SUM(H.tongTien) as DoanhThu
						      FROM HoaDon H, DatPhong D, LoaiPhong L, KhachSan K
						      WHERE H.maDP=D.maDP AND D.maLoaiPhong=L.maLoaiPhong AND L.maKS=K.maKS'
			---IF(@hotelname IS NULL) ---không báo cáo theo khách sạn --không làm gì cả
			IF(@hotelname IS NOT NULL)---báo cáo theo khách sạn
				SET @sqlstring = @sqlstring + ' AND K.tenKS LIKE N''%' +@hotelname + '%'''
			---IF(@m IS NULL AND @y IS NULL) ---tháng bất kỳ, năm bất kỳ ---không làm gì hết
			IF(@m IS NULL AND @y IS NOT NULL) ---tháng bất kỳ, năm cho trước
				SET @sqlstring = @sqlstring + ' AND DATEPART(YEAR,H.ngayThanhToan) = @y'	
			IF(@m IS NOT NULL AND @y IS NOT NULL) ---tháng cho trước, năm cho trươc
				SET @sqlstring = @sqlstring + ' AND DATEPART(YEAR,H.ngayThanhToan) = @y AND DATEPART(MONTH,H.ngayThanhToan) = @m'
			---thêm phần group by và order
			SET @sqlstring = @sqlstring + ' GROUP BY DATEPART(MONTH,H.ngayThanhToan), DATEPART(YEAR,H.ngayThanhToan), K.maKS, K.tenKS'
			SET @sqlstring = @sqlstring + ' ORDER BY K.maKS'
		END

	END

ELSE IF((@option = N'Năm' AND @m IS NULL AND @y IS NOT NULL)
   OR (@option = N'Năm' AND @m IS NULL AND @y IS NULL)) ---báo cáo doanh thu theo năm

BEGIN
	SET @sqlstring = 'SELECT K.maKS, K.tenKS,DATEPART(YEAR,H.ngayThanhToan) as Nam, SUM(H.tongTien) as DoanhThu
					  FROM HoaDon H, DatPhong D, LoaiPhong L, KhachSan K
					  WHERE H.maDP=D.maDP AND D.maLoaiPhong=L.maLoaiPhong AND L.maKS=K.maKS'
	---IF(@hotelname IS NULL) ---không báo cáo theo khách sạn--không làm gì cả
	IF(@hotelname IS NOT NULL)---báo cáo theo khách sạn
		SET @sqlstring = @sqlstring + ' AND K.tenKS LIKE N''%' +@hotelname + '%'''
	--IF(@y IS NULL) --theo năm bất kỳ ---không làm gì cả
	IF(@y IS NOT NULL)
		SET @sqlstring = @sqlstring + ' AND DATEPART(YEAR,H.ngayThanhToan) = @y'
	--thêm group by và order
	SET @sqlstring = @sqlstring + ' GROUP BY DATEPART(YEAR,H.ngayThanhToan), K.maKS, K.tenKS'
	SET @sqlstring = @sqlstring + ' ORDER BY K.maKS'
END

ELSE
BEGIN
	RAISERROR (N'Lỗi! Không thể báo cáo doanh thu theo năm theo định dạng này. Báo cáo theo năm phải có tháng là rỗng',16,1);
	RETURN
END
SET @input = ' @option NVARCHAR(10), @hotelname NVARCHAR(50), @m INT, @y INT '
EXEC SP_EXECUTESQL @sqlstring,
				   @input,
				   @option,
				   @hotelname,
				   @m,
				   @y
END
