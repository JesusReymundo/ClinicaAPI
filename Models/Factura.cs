using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Comprobante")]
public class Factura   // Clase mantenida como Factura para no romper referencias existentes
{
    [Key]
    public int IdComprobante { get; set; }
    public int IdCita { get; set; }
    [Required, MaxLength(20)]
    public string TipoComprobante { get; set; } = "Boleta";   // Boleta / Factura
    [MaxLength(5)]
    public string Serie { get; set; } = "B001";
    [Required, MaxLength(20)]
    public string Numero { get; set; } = string.Empty;
    [Column(TypeName = "decimal(10,2)")]
    public decimal Subtotal { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal IGV { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal Total { get; set; }
    [MaxLength(20)]
    public string EstadoPago { get; set; } = "Pendiente";
    [MaxLength(50)]
    public string? MetodoPago { get; set; }
    [MaxLength(50)]
    public string? NroOperacion { get; set; }
    public DateTime? FechaPago { get; set; }
    public DateTime FechaEmision { get; set; } = DateTime.Now;
    public int? IdUsuarioCreacion { get; set; }
    public int? IdUsuarioModificacion { get; set; }

    [ForeignKey("IdCita")]
    public Cita? Cita { get; set; }
}
