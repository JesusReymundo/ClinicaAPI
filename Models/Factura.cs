using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ClinicaAPI.Models;

[Table("Facturas")]
public class Factura
{
    [Key]
    public int IdFactura { get; set; }
    public int IdCita { get; set; }
    [Required, MaxLength(20)]
    public string NumeroFactura { get; set; } = string.Empty;
    [MaxLength(5)]
    public string Serie { get; set; } = "F001";
    [Column(TypeName = "decimal(10,2)")]
    public decimal Subtotal { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal IGV { get; set; }
    [Column(TypeName = "decimal(10,2)")]
    public decimal Total { get; set; }
    [MaxLength(20)]
    public string EstadoPago { get; set; } = "Pendiente";
    public DateTime FechaEmision { get; set; } = DateTime.Now;

    [ForeignKey("IdCita")]
    public Cita? Cita { get; set; }
}
